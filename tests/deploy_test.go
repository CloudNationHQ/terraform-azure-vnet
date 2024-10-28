package main

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

type TerraformModule struct {
	Name    string
	Path    string
	Options *terraform.Options
}

func NewTerraformModule(name, path string) *TerraformModule {
	return &TerraformModule{
		Name: name,
		Path: path,
		Options: &terraform.Options{
			TerraformDir: path,
			NoColor:      true,
		},
	}
}

func (m *TerraformModule) Apply(t *testing.T) {
	t.Logf("Applying Terraform module: %s", m.Name)
	terraform.WithDefaultRetryableErrors(t, m.Options)
	terraform.InitAndApply(t, m.Options)
}

func (m *TerraformModule) Destroy(t *testing.T) {
	t.Logf("Destroying Terraform module: %s", m.Name)
	terraform.Destroy(t, m.Options)
	m.cleanupFiles(t)
}

func (m *TerraformModule) cleanupFiles(t *testing.T) {
	t.Logf("Cleaning up in: %s", m.Options.TerraformDir)
	filesToCleanup := []string{"*.terraform*", "*tfstate*"}
	for _, pattern := range filesToCleanup {
		matches, err := filepath.Glob(filepath.Join(m.Options.TerraformDir, pattern))
		if err != nil {
			t.Errorf("Error matching pattern %s: %v", pattern, err)
			continue
		}
		for _, filePath := range matches {
			if err := os.RemoveAll(filePath); err != nil {
				t.Errorf("Failed to remove %s: %v", filePath, err)
			}
		}
	}
}

func TestApplyNoError(t *testing.T) {
	t.Parallel()

	example := os.Getenv("EXAMPLE")
	if example == "" {
		t.Fatal("EXAMPLE environment variable is not set")
	}

	modulePath := filepath.Join("..", "examples", example)
	module := NewTerraformModule(example, modulePath)

	t.Run(module.Name, func(t *testing.T) {
		defer module.Destroy(t)
		module.Apply(t)
	})
}
