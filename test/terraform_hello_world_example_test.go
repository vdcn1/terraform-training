package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	"net/http"
	"testing"
	"time"
)

func TestTerraformHelloWorldExample(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.

	awsRegion := "us-east-2"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../instances",
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables and check they have the expected values.
	instance_id := terraform.Output(t, terraformOptions, "instance_id")

	tags := aws.GetTagsForEc2Instance(t, awsRegion, instance_id)

	var name_compare = "Flugel"
	var owner_compare = "InfraTeam"

	// Run `terraform output` to get the value of an output variable
	instanceURLTags := "http://" + terraform.Output(t, terraformOptions, "public_ip") + ":5000/tags"
	instanceURLShutdown := "http://" + terraform.Output(t, terraformOptions, "public_ip") + ":5000/shutdown"

	fmt.Println(instanceURLTags)

	// Specify the text the EC2 Instance will return when we make HTTP requests to it.
	instanceText := fmt.Sprintf("[{'Key': 'Owner', 'Value': '%s'}, {'Key': 'Name', 'Value': '%s'}]", tags["Owner"], tags["Name"])
	instanceTextAlt := fmt.Sprintf("[{'Key': 'Name', 'Value': '%s'}, {'Key': 'Owner', 'Value': '%s'}]", tags["Name"], tags["Owner"])

	// It can take a minute or so for the Instance to boot up, so retry a few times: (waiting a few seconds)
	time.Sleep(100 * time.Second)

	resp, err := http.Get(instanceURLTags)

	if err != nil {
		fmt.Println(err)
	}

	body, _ := ioutil.ReadAll(resp.Body)
	fmt.Println(string(body))
	//assert.Equal(t, instanceText, string(body))

	assert.Condition(t, func() bool {
		if (instanceText == string(body)) || (instanceTextAlt == string(body)) {
			return true
		} else {
			return false
		}
	})

	resp, err = http.Get(instanceURLShutdown)

	if err != nil {
		fmt.Println(err)
	}

	body, _ = ioutil.ReadAll(resp.Body)
	fmt.Println(string(body))
	assert.Equal(t, "Shuting down...\n", string(body))

	assert.Equal(t, name_compare, tags["Name"])
	assert.Equal(t, owner_compare, tags["Owner"])

	// Verify that we get back a 200 OK with the expected instanceText
	// http_helper.HttpGetWithRetry(t, instanceURLTags, &tlsConfig, 200, instanceText, maxRetries, timeBetweenRetries)
	// http_helper.HttpGetWithRetry(t, instanceURLShutdown, &tlsConfig, 200, "Shuting down...", maxRetries, timeBetweenRetries)
}
