/*
 */

plugins {
    id("com.gradle.devlocity") version ("3.17.3")
    id("com.gradle.common-custom-user-data-gradle-plugin") version ("1.13")
}

rootProject.name = "marco-gradle-kts"

develocity {
    server = "https://develicity-field.gradle.com"
    allowUntrustedServer.set(true)

    buildScan {
        capture { isTaskInputFiles = true }
        isUploadInBackground = true
        publishAlways()
    }
}

buildCache {
    local {
        isEnabled = true
    }
    remote(develocity.buildCache) {
        isEnabled = true
        isPush = true
    }
}
