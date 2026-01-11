allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Suppress obsolete '-source'/'-target' warnings from javac by disabling the
// specific lint. This keeps the Gradle output quieter while the project uses
// a modern Java toolchain (set via `compileOptions` in module build files).
tasks.withType<JavaCompile> {
    options.compilerArgs.add("-Xlint:-options")
}
