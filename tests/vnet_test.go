package main

import (
	"os"
	"testing"

	"github.com/cloudnationhq/terraform-azure-vnet/shared"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestApplyNoError(t *testing.T) {
	t.Parallel()

	tests := []shared.TestCase{
		{Name: os.Getenv("TF_PATH"), Path: "../examples/" + os.Getenv("TF_PATH")},
	}

	for _, test := range tests {
		t.Run(test.Name, func(t *testing.T) {
			terraformOptions := shared.GetTerraformOptions(test.Path)

			terraform.WithDefaultRetryableErrors(t, &terraform.Options{})

			defer shared.Cleanup(t, terraformOptions)
			terraform.InitAndApply(t, terraformOptions)
		})
	}
}
