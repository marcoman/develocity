/*
 * This file contains representative examples of how to configure
 * your build files.
 */


// See the documentation at https://docs.gradle.com/develocity/flaky-test-detection/ for how to configure the following
tasks.withType<Test>().configureEach {
    develocity.testRetry {
        maxRetries.set(3)
        failOnPassedAfterRetry.set(true)
    }
}
