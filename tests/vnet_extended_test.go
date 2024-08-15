package main

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork"
	"github.com/cloudnationhq/terraform-azure-vnet/shared"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

type VnetDetails struct {
	ResourceGroupName string
	Name              string
	Subnets           []SubnetDetails
}

type SubnetDetails struct {
	Name                   string
	NetworkSecurityGroupID string
}

type ClientSetup struct {
	SubscriptionID       string
	VirtualNetworkClient *armnetwork.VirtualNetworksClient
	SubnetsClient        *armnetwork.SubnetsClient
}

func (details *VnetDetails) GetVnet(t *testing.T, client *armnetwork.VirtualNetworksClient) *armnetwork.VirtualNetwork {
	resp, err := client.Get(context.Background(), details.ResourceGroupName, details.Name, nil)
	require.NoError(t, err, "Failed to get vnet details")
	return &resp.VirtualNetwork
}

func (details *VnetDetails) GetSubnets(t *testing.T, client *armnetwork.SubnetsClient) []SubnetDetails {
	pager := client.NewListPager(details.ResourceGroupName, details.Name, nil)

	var subnets []SubnetDetails
	for {
		page, err := pager.NextPage(context.Background())
		require.NoError(t, err, "Failed to list subnets")
		for _, subnet := range page.Value {
			subnets = append(subnets, SubnetDetails{
				Name:                   *subnet.Name,
				NetworkSecurityGroupID: *subnet.Properties.NetworkSecurityGroup.ID,
			})
		}

		if page.NextLink == nil || len(*page.NextLink) == 0 {
			break
		}
	}
	return subnets
}

func (setup *ClientSetup) InitializeVirtualNetworkClient(t *testing.T, cred *azidentity.DefaultAzureCredential) {
	var err error
	setup.VirtualNetworkClient, err = armnetwork.NewVirtualNetworksClient(setup.SubscriptionID, cred, nil)
	require.NoError(t, err, "Failed to initialize virtual network client")
}

func (setup *ClientSetup) InitializeSubnetsClient(t *testing.T, cred *azidentity.DefaultAzureCredential) {
	var err error
	setup.SubnetsClient, err = armnetwork.NewSubnetsClient(setup.SubscriptionID, cred, nil)
	require.NoError(t, err, "Failed to initialize subnets client")
}

func TestVirtualNetwork(t *testing.T) {
	t.Run("VerifyVirtualNetworkAndSubnets", func(t *testing.T) {
		t.Parallel()

		tfOpts := shared.GetTerraformOptions("../examples/complete")
		defer shared.Cleanup(t, tfOpts)
		terraform.InitAndApply(t, tfOpts)

		vnet := terraform.OutputMap(t, tfOpts, "vnet")
		virtualNetworkName, ok := vnet["name"]
		require.True(t, ok, "Virtual network name not found in terraform output")

		resourceGroupName, ok := vnet["resource_group_name"]
		require.True(t, ok, "Resource group name not found in terraform output")

		subscriptionID := terraform.Output(t, tfOpts, "subscription_id")
		require.NotEmpty(t, subscriptionID, "Subscription ID not found in terraform output")

		cred, err := azidentity.NewDefaultAzureCredential(nil)
		if err != nil {
			t.Fatalf("failed to get credentials: %+v", err)
		}

		clientSetup := &ClientSetup{
			SubscriptionID: subscriptionID,
		}

		clientSetup.InitializeVirtualNetworkClient(t, cred)
		clientSetup.InitializeSubnetsClient(t, cred)

		vnetDetails := &VnetDetails{
			ResourceGroupName: resourceGroupName,
			Name:              virtualNetworkName,
		}

		virtualNetwork := vnetDetails.GetVnet(t, clientSetup.VirtualNetworkClient)

		t.Run("VerifyVirtualNetwork", func(t *testing.T) {
			verifyVirtualNetwork(t, vnetDetails, virtualNetwork)
		})

		t.Run("VerifySubnetsExist", func(t *testing.T) {
			verifySubnetsExist(t, clientSetup, vnetDetails, tfOpts)
		})
	})
}

func verifyVirtualNetwork(t *testing.T, details *VnetDetails, vnet *armnetwork.VirtualNetwork) {
	t.Helper()

	require.Equal(
		t,
		details.Name,
		*vnet.Name,
		"Vnet name does not match expected value",
	)

	require.Equal(
		t,
		"Succeeded",
		string(*vnet.Properties.ProvisioningState),
		"Vnet provisioning state is not 'Succeeded'",
	)
}

func verifySubnetsExist(t *testing.T, setup *ClientSetup, vnetDetails *VnetDetails, tfOpts *terraform.Options) {
	t.Helper()

	subnetsData := vnetDetails.GetSubnets(t, setup.SubnetsClient)

	subnetsOutput := terraform.OutputMap(t, tfOpts, "subnets")
	require.NotEmpty(t, subnetsOutput, "Subnets output is empty")

	for _, subnetData := range subnetsData {
		subnetName := subnetData.Name
		assert.NotEmpty(
			t,
			subnetName,
			"Subnet name not found in Azure response",
		)

		_, exists := subnetsOutput[subnetName]
		assert.True(
			t,
			exists,
			"Subnet name %s not found in Terraform output",
			subnetName,
		)

		assert.NotEmpty(
			t,
			subnetData.NetworkSecurityGroupID,
			"No network security group association found for subnet %s",
			subnetName,
		)
	}
}
