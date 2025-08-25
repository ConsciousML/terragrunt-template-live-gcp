package tests

import (
	"os/exec"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestFooBarLocalStack(t *testing.T) {
	t.Parallel()

	stackDir := "../live/staging/"

	t.Logf("Running test in stackDir: %s", stackDir)

	// Ensure destroy runs at the end, even if the test fails
	t.Cleanup(func() {
		t.Log("Running cleanup: terragrunt destroy...")
		cmdDestroy := exec.Command("terragrunt", "run", "--all", "destroy", "--no-stack-generate", "--non-interactive")
		cmdDestroy.Dir = stackDir
		out, err := cmdDestroy.CombinedOutput()
		t.Logf("Destroy output:\n%s", out)
		require.NoError(t, err, "stack run destroy failed: %s", string(out))
	})

	// Generate
	t.Log("Running: terragrunt stack generate...")
	cmdGenerate := exec.Command("terragrunt", "stack", "generate")
	cmdGenerate.Dir = stackDir
	out, err := cmdGenerate.CombinedOutput()
	t.Logf("Generate output:\n%s", out)
	require.NoError(t, err, "stack generate failed: %s", string(out))

	// Apply
	t.Log("Running: terragrunt run --all apply...")
	cmdApply := exec.Command("terragrunt", "run", "--all", "apply", "--no-stack-generate", "--backend-bootstrap", "--non-interactive")
	cmdApply.Dir = stackDir
	out, err = cmdApply.CombinedOutput()
	t.Logf("Apply output:\n%s", out)
	require.NoError(t, err, "run --all apply failed: %s", string(out))
}
