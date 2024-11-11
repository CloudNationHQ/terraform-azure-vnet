## Testing

Ensure Go and Terraform are installed.

Run tests for different scenarios by setting the example flag when running the tests.

To run a test, use make test example=default, replacing default with the example you want to test from the examples directory.

Add skip-destroy=true to skip the destroy step, like make test example=default skip-destroy=true.

For running all tests in parallel or sequentially with make test-parallel or make test-sequential, exclude specific examples by adding exception=example1,example2, where example1 and example2 are examples to skip.

These tests ensure the module's reliability across configurations.
