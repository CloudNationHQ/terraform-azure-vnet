package tests

import (
	"testing"

	"github.com/cloudnationhq/az-cn-go-validor"
)

func TestApplyNoError(t *testing.T) {
	validor.TestApplyNoError(t)
}

func TestApplyAllParallel(t *testing.T) {
	validor.TestApplyAllParallel(t)
}

func TestApplyAllSequential(t *testing.T) {
	validor.TestApplyAllSequential(t)
}

func TestApplyAllLocal(t *testing.T) {
	validor.TestApplyAllLocal(t)
}
