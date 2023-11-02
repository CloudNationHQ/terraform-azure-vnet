.PHONY: test test_extended

export TF_PATH

test:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/$(TF_PATH) ./vnet_test.go

test_extended:
	cd tests && env go test -v -timeout 60m -run TestVirtualNetwork ./vnet_extended_test.go
