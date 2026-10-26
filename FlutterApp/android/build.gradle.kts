allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir { dirs("${rootProject.projectDir}/unityLibrary/libs") }
    }
}
val output = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(output)
subprojects {
    layout.buildDirectory.value(output.dir(project.name))
    evaluationDependsOn(":app")
}
tasks.register<Delete>("clean") { delete(rootProject.layout.buildDirectory) }
