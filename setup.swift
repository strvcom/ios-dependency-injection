#!/usr/bin/env swift
import Foundation

// swiftlint:disable all

let shell = Shell()
// This enables the script to exit when the user presses Ctrl+C
signal(SIGINT) { _ in
    Task { @MainActor in
        shell.terminateCurrentTask()
        exit(0)
    }
}

enum Command: String, CaseIterable {
    case help
    case setup
    case install
    case installBundle = "install-bundle"
    case installDependencies = "install-dependencies"
    case updateDependencies = "update-dependencies"
    case setupTuist = "setup-tuist"
    case setupHooks = "setup-hooks"
    case renameProject = "rename-project"
    case setupCI = "setup-ci"
    case removeTuistFiles = "remove-tuist-files"
    case setupVersionIcon = "install-version-icon"
}

extension Command {
    var description: String {
        switch self {
        case .help:
            "Prints this manual."

        case .setup:
            "Runs the following commands: setupCI -> renameProject -> setupHooks -> installMiseDependencies -> installBundle -> setupTuist (if needed) -> setupVersionIcon."

        case .install:
            "Runs the following commands: setupHooks -> installMiseDependencies -> installBundle -> installTuistDependencies -> installVersionIcon (if needed)."

        case .installBundle:
            "We use Gemfile to ensure that you have all dependencies in correct versions. `install-bundle` installs all dependencies to the project directory."

        case .installDependencies:
            "Installs Mise and Tuist dependencies (Tuist, SwiftLint, SwiftFormat) if needed."

        case .updateDependencies:
            "Updates dependencies (Tuist, SwiftLint, SwiftFormat) to the latest versions"

        case .setupTuist:
            "Installs Tuist environment, installs dependencies and generates the project files, adds appropriate files to the gitignore, removes gitignored files from git and setups git hooks."

        case .setupHooks:
            "Creates symbolic links for hooks in githooks to the .git/hooks dictionary."

        case .renameProject:
            "If you want to rename the project from `STRVTemplate` to something different (and you probably want that), just run the following command. You'll be asked for the name."

        case .setupCI:
            "Copies .env and workflow files as needed."

        case .removeTuistFiles:
            "Removes Tuist definition files."

        case .setupVersionIcon:
            "VersionIcon is optional feature. It creates an app icon overlay with the ribbon and/or version (build) text based on the app configuration. VersionIcon is added as script build phase. It is STRV internal project and it is highly customizable."
        }
    }
}

enum SetupError: LocalizedError {
    case fileOperationFailed(String? = nil)
    case emptyProjectName
    case missingWorkspace
    case miseNotInstalled(command: String)
    case miseNotActivated(command: String)

    var errorDescription: String? {
        switch self {
        case let .fileOperationFailed(error?):
            "file operation failed: \(error)"
        case .fileOperationFailed(.none):
            "file operation failed"
        case .emptyProjectName:
            "project name can't be empty"
        case .missingWorkspace:
            "no workspace in current directory"
        case let .miseNotInstalled(command):
            "Please install Mise (https://mise.jdx.dev/getting-started.html#_1-install-mise-cli) and run the `\(command)` command again."
        case let .miseNotActivated(command):
            "Please activate Mise (https://mise.jdx.dev/getting-started.html#_2a-activate-mise) and run the `\(command)` command again."
        }
    }
}

@MainActor
final class Main {
    private let commandRunner = CommandRunner()

    func run() async {
        let argumentCommand = CommandLine.argc > 1 ? CommandLine.arguments[1] : nil

        if let argumentCommand {
            if let command = Command(rawValue: argumentCommand) {
                await commandRunner.run(command)
            } else {
                print("⚠️ Error: unknown command")
                exit(1)
            }
        } else {
            await askForCommand()
        }
    }
}

private extension Main {
    func askForCommand() async {
        printCommands()
        print("\n")
        if let commandNumber = askForCommandNumber(),
           Command.allCases.indices.contains(commandNumber)
        {
            let command = Command.allCases[commandNumber]
            print("  Next time you can do this by directly typing `./setup.swift \(command.rawValue)`")
            await commandRunner.run(command)
        } else {
            print("⚠️ Error: unknown command")
            exit(1)
        }
    }

    func printCommands() {
        for (index, command) in Command.allCases.enumerated() {
            print("\(index): \(command.rawValue)")
        }
    }

    func askForCommandNumber() -> Int? {
        print("\n💬  Which number would you like to run?")
        return readLine().map(Int.init) ?? nil
    }
}

@MainActor
final class CommandRunner {
    func run(_ command: Command) async {
        do {
            switch command {
            case .help:
                printManual()

            case .installBundle:
                try await installBundle(shouldVerifyMise: true)

            case .installDependencies:
                let tuistDefinitionFileExists = await tuistDefinitionFileExists()
                try await installMiseDependencies(shouldVerifyMise: true)
                try await installTuistDependencies(isUsingTuist: tuistDefinitionFileExists)

            case .updateDependencies:
                await updateDependencies()

            case .setupTuist:
                try await verifyMiseIsInstalled(command: command)
                try await setupTuist()

            case .setupHooks:
                try setupHooks()

            case .renameProject:
                try await renameProject()

            case .setupCI:
                await setupCI()

            case .setup:
                try await setup()

            case .install:
                try await install()

            case .removeTuistFiles:
                await removeTuistFiles()

            case .setupVersionIcon:
                let tuistDefinitionFileExists = await tuistDefinitionFileExists()
                if tuistDefinitionFileExists {
                    try? await setupVersionIcon(projectName: nil)
                    try await installTuistDependencies(isUsingTuist: tuistDefinitionFileExists)
                } else {
                    print("⚠️ Error: VersionIcon requires Tuist and it is not installed. Please run `./setup.swift setup-tuist` first.")
                    exit(1)
                }
            }
        } catch {
            print("⚠️ Error: \(error.localizedDescription)")
            exit(1)
        }
    }
}

private extension CommandRunner {
    var isCI: Bool {
        guard let ciValue = ProcessInfo.processInfo.environment["CI"] else {
            return false
        }
        return ciValue == "true" || ciValue == "1"
    }

    var homeDirectory: String {
        FileManager.default.homeDirectoryForCurrentUser.path
    }

    func printManual() {
        print("\n🔵  Available commands:\n")
        for (index, command) in Command.allCases.enumerated() {
            print("\(index): \(command.rawValue)")
            print("// \(command.description)\n")
        }
    }

    func setup() async throws {
        try await verifyMiseIsInstalled(command: .setup)
        await setupCI(offerSkip: true)
        let projectName = try await renameProject()
        try setupHooks()
        try await installMiseDependencies(shouldVerifyMise: false)
        try await installBundle(shouldVerifyMise: false)
        try await setupVersionIcon(projectName: projectName)
        try await setupTuist()
    }

    func install() async throws {
        try await verifyMiseIsInstalled(command: .install)
        try setupHooks()
        let tuistDefinitionFileExists = await tuistDefinitionFileExists()
        try await installMiseDependencies(shouldVerifyMise: false)
        try await installBundle(shouldVerifyMise: false)
        try await installTuistDependencies(isUsingTuist: tuistDefinitionFileExists)
        try installVersionIconIfNeeded()
    }

    func installBundle(shouldVerifyMise: Bool) async throws {
        if shouldVerifyMise {
            try await verifyMiseIsInstalled(command: .installBundle)
        }

        print("🔵  Install bundle: \(bundlerVersion)")
        await shell.runAndExitIfFailure("./scripts/setup_bundler.sh")
        await shell.runAndExitIfFailure("bundle _\(bundlerVersion)_ install")
    }

    func installMiseDependencies(shouldVerifyMise: Bool) async throws {
        if shouldVerifyMise {
            try await verifyMiseIsInstalled(command: .installDependencies)
        }

        print("🔵  Install Mise dependencies")

        await shell.runAndExitIfFailure("mise install -y")
    }

    func installTuistDependencies(isUsingTuist: Bool) async throws {
        print("🔵  Install Tuist dependencies")

        if isUsingTuist {
            // It seems we need to use `mise exec` because after the initial Mise installation the $PATH doesn't correctly update
            // not even via calling `eval "$(mise activate zsh --shims)"` so Mise is unable to find the correct tool (in this case tuist)
            // Every other setup run works correctly without calling `mise exec` because the $PATH updating is the working fine.
            // But for the initial "edge-case" it seems we need to keep the `mise exec`.
            await shell.runAndExitIfFailure("mise exec -- tuist install")
            await shell.runAndExitIfFailure("mise exec -- tuist generate --no-open")
        }
    }

    func updateDependencies() async {
        await shell.runAndExitIfFailure("ruby scripts/update_dependencies.rb")
    }

    func setupTuist() async throws {
        print("🔵  Setup Tuist")
        guard await tuistDefinitionFileExists() else {
            print("Tuist Project.swift definition file is missing.")
            return
        }
        try await installTuistDependencies(isUsingTuist: true)

        await shell.runAndExitIfFailure("./scripts/setup_tuist_githook.sh")
        try setupHooks()
    }

    func setupHooks() throws {
        guard !isCI else {
            return
        }

        print("🔵  Setup hooks")
        try installHooks()
    }

    func installHooks() throws {
        let fileManager = FileManager.default
        let currentDirectoryPath = fileManager.currentDirectoryPath
        let hooksDirectoryPath = currentDirectoryPath + "/.git/hooks"
        let sourceDirectoryPath = currentDirectoryPath + "/.githooks"

        if !fileManager.fileExists(atPath: hooksDirectoryPath) {
            print("🟡 Creating missing .git/hooks/ directory")
            try fileManager.createDirectory(atPath: hooksDirectoryPath, withIntermediateDirectories: true, attributes: nil)
        }

        let hooks = try fileManager.contentsOfDirectory(atPath: sourceDirectoryPath)
            .filter { !$0.hasPrefix(".") && URL(fileURLWithPath: $0).pathExtension.isEmpty }

        for hook in hooks {
            let target = currentDirectoryPath + "/.git/hooks/\(hook)"
            let source = currentDirectoryPath + "/.githooks/\(hook)"
            let backup = "\(target).bak"

            guard fileManager.fileExists(atPath: source) else {
                print("🟡  Skipping \(hook) hook because it doesn't exist at expected path: \(source)")
                continue
            }

            if
                let destination = try? fileManager.destinationOfSymbolicLink(atPath: target),
                destination == source
            {
                print("🟢  \(hook) hook is already installed")
                continue
            }

            if fileManager.contentsEqual(atPath: target, andPath: source) {
                print("🟢  \(hook) hook is already installed")
                continue
            }

            if fileManager.fileExists(atPath: target) {
                print("🟡  Found an existing hook for \(hook). Creating a backup at \(backup)")
                do {
                    if fileManager.fileExists(atPath: backup) {
                        try fileManager.removeItem(atPath: backup)
                    }
                    try fileManager.moveItem(atPath: target, toPath: backup)
                } catch {
                    throw SetupError.fileOperationFailed("Backup creation failed: \(error.localizedDescription)")
                }
            }

            do {
                try fileManager.createSymbolicLink(atPath: target, withDestinationPath: source)
            } catch {
                throw SetupError.fileOperationFailed("\(hook) Symlink creation failed: \(error.localizedDescription)")
            }
            print("🟢  Installed \(hook) hook")
        }
    }

    @discardableResult
    func renameProject() async throws -> String {
        print("\n🔵  Rename project")
        print("💬  New project name:")
        guard let projectName = readLine(), !projectName.isEmpty else {
            throw SetupError.emptyProjectName
        }
        print("🔵  Renaming project... (can take a minute)")
        await shell.runAndExitIfFailure("./scripts/rename.sh \"\(projectName)\"")
        print("🟢  Renamed to \(projectName)")
        return projectName
    }

    func setupCI(offerSkip: Bool = false) async {
        print("🔵  Setup CI")

        print("🔵  Setting up default Integrations workflow")
        await shell.runAndExitIfFailure("./scripts/setup_ci.sh integrations")

        let availableWorkflows = [
            "testflight",
            "enterprise",
        ]
        let workflowsString = availableWorkflows
            .enumerated()
            .map { "\($0): \($1)" }
            .joined(separator: " | ")
        print("\n🔵  Available CI workflows: \(workflowsString)")
        print("💬  Which workflow number would you like to select?" + (offerSkip ? " Just press enter to skip." : ""))
        if let workflowNumber = readLine().map(Int.init) ?? nil,
           availableWorkflows.indices.contains(workflowNumber)
        {
            let selectedWorkflow = availableWorkflows[workflowNumber]
            await shell.runAndExitIfFailure("./scripts/setup_ci.sh \"\(selectedWorkflow)\"")
        } else {
            print("🔵  Skipped")
        }
    }

    func removeTuistFiles() async {
        print("🔵  Remove Tuist files")
        await shell.runAndExitIfFailure("rm -rf Tuist App/Project.swift Workspace.swift .tuist-version .githooks/post-checkout .package.resolved Derived")
    }

    func tuistDefinitionFileExists() async -> Bool {
        await shell.run("test -e App/Project.swift") == 0
    }

    func shouldSetupVersionIcon() -> Bool {
        print("\n💬  Do you want to setup VersionIcon script (https://github.com/strvcom/ios-version-icon) ? (y/n)")
        let answer = readLine()
        if answer == "y" {
            return true
        } else if answer == "n" {
            return false
        } else {
            print("⚠️ Unknown answer")
            exit(1)
        }
    }

    func setupVersionIcon(projectName: String?) async throws {
        // Test whether Tuist is installed
        var isdirectory : ObjCBool = true
        guard FileManager.default.fileExists(atPath: "Tuist", isDirectory: &isdirectory) else {
            print("⚠️ Tuist is not installed")
            return
        }

        guard shouldSetupVersionIcon() else {
            return
        }

        var usedProjectName: String
        if let projectName {
            usedProjectName = projectName
        } else {
            let currentDirectory = FileManager.default.currentDirectoryPath
            let enumerator = FileManager.default.enumerator(atPath: currentDirectory)
            let filePaths = enumerator?.allObjects as! [String]
            let workspaces = filePaths.filter { $0.contains(".xcworkspace") }

            usedProjectName = try getProjectName(from: workspaces)
        }
        try setupVersionIconGlobalConstants()
        try setupVersionIconUpdateGitIgnore(projectName: usedProjectName)
        await setupVersionIconRemoveIconsFromGit(projectName: usedProjectName)
    }

    /// Gets the name for project - from the workspace file or by asking the user
    func getProjectName(from workspaces: [String]) throws -> String {
        // Handle the case that there are many workspace files in the folder
        if workspaces.count > 1 {
            // Ask the user
            print("\n💬  Project name: ")
            guard let projectName = readLine(), !projectName.isEmpty else {
                throw SetupError.emptyProjectName
            }
            return projectName
        }
        // Otherwise derive the project name from single workspace file
        else {
            guard let workspace = workspaces.first else {
                throw SetupError.missingWorkspace
            }

            return workspace.replacingOccurrences(of: ".xcworkspace", with: "")
        }
    }

    /// Change Tuist GlobalConstants.swift
    func setupVersionIconGlobalConstants() throws {
        print("🔵  Modifying Tuist GlobalConstants")
        var globalConstantsContents = try String(contentsOfFile: globalConstantsPath, encoding: .utf8)
        globalConstantsContents = globalConstantsContents.replacing("useVersionIcon = false", with: "useVersionIcon = true")
        try globalConstantsContents.write(toFile: globalConstantsPath, atomically: true, encoding: .utf8)
    }

    /// Update .gitignore for VersionIcon
    func setupVersionIconUpdateGitIgnore(projectName: String) throws {
        print("🔵  Updating .gitignore")
        let gitIgnore = ".gitignore"
        var gitIgnoreContents = try String(contentsOfFile: gitIgnore)

        if gitIgnoreContents.contains("AppIcon.appiconset") {
            print("VersionIcon is already set in .gitignore")
        } else {
            gitIgnoreContents.append(
                """

                # VersionIcon

                App/{{AppName}}/Application/Resources/Assets.xcassets/AppIcon.appiconset/*
                """
                .replacing("{{AppName}}", with: projectName)
            )
            try gitIgnoreContents.write(toFile: gitIgnore, atomically: true, encoding: .utf8)
        }
    }

    /// Remove icon files from git. We want to avoid commiting the changed icons with every commit.
    /// AppIcon is now cosidered as only local and AppIconOriginal is shared image source.
    func setupVersionIconRemoveIconsFromGit(projectName: String) async {
        print("🔵  Removing AppIcon images from git")
        await shell.runAndExitIfFailure("git rm -f \"App/\(projectName)/Application/Resources/Assets.xcassets/AppIcon.appiconset/*\"")
    }

    /// Installs VersionIcon if needed.
    /// `AppIcon` is git ignored, but Xcode still needs it to build the app.
    /// We copy the original icon to `AppIcon.appiconset` if it doesn't exist.
    /// This usually happens when existing project is cloned and the icon is not present.
    func installVersionIconIfNeeded() throws {
        guard try isVersionIconSetup() else {
            print("🔵  VersionIcon is not set up. Skipping.")
            return
        }

        guard let projectName = try getGlobalConstantsProjectName() else {
            print("🔴  Could not determine project name from GlobalConstants.swift. Please ensure it is set correctly.")
            return
        }
        let originalAppIconPath = "App/\(projectName)/Application/Resources/Assets.xcassets/AppIconOriginal.appiconset"
        let appIconPath = "App/\(projectName)/Application/Resources/Assets.xcassets/AppIcon.appiconset"

        guard FileManager.default.fileExists(atPath: originalAppIconPath) else {
            print("🔴  Original AppIcon not found at \(originalAppIconPath). Please ensure it exists.")
            return
        }

        guard !FileManager.default.fileExists(atPath: appIconPath) else {
            print("🟢  AppIcon is already set up.")
            return
        }

        try FileManager.default.copyItem(atPath: originalAppIconPath, toPath: appIconPath)
        print("🟢  Copied original AppIcon to \(appIconPath)")
    }

    func isVersionIconSetup() throws -> Bool {
        let contents = try String(contentsOfFile: globalConstantsPath, encoding: .utf8)
        return contents.contains("useVersionIcon = true")
    }

    var bundlerVersion: String {
        let fileName = ".bundler-version"
        let fileURL = URL(filePath: fileName)
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("⚠️ Error: \(String(describing: error))")
            exit(1)
        }
    }

    func getGlobalConstantsProjectName() throws -> String? {
        let globalConstantsContents = try String(contentsOfFile: globalConstantsPath, encoding: .utf8)
        let pattern = #".*projectName\s*=\s*"([^"]+)""#
        let regex = try NSRegularExpression(pattern: pattern, options: [])

        if let match = regex.firstMatch(in: globalConstantsContents, options: [], range: NSRange(globalConstantsContents.startIndex..., in: globalConstantsContents)),
           let range = Range(match.range(at: 1), in: globalConstantsContents)
        {
            let projectName = String(globalConstantsContents[range])
            return projectName
        }

        return nil
    }

    var globalConstantsPath: String {
        "./Tuist/ProjectDescriptionHelpers/GlobalConstants.swift"
    }

    func promptWithDefault(message: String, defaultValue: String = "y") -> String {
        print("\(message) [Y/n]: ", terminator: "")

        let response = readLine()?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let response, !response.isEmpty {
            return response
        }
        return defaultValue
    }
}

// MARK: - Mise setup

private extension CommandRunner {
    /// Checks if Mise is installed, verifies if activated correctly, and handles installation + activation if necessary.
    func verifyMiseIsInstalled(command: Command) async throws {
        // If Mise is installed
        if await shell.run("which -s mise", printOutput: false) == 0 {
            print("🔵  Mise is installed.")
        } else {
            // Check whether it is installed in the expected path
            if FileManager.default.fileExists(atPath: "\(homeDirectory)/.local/bin/mise") {
                print("🟡  Mise is installed, but not activated.")
                let isZshrcUpdated = await verifyAndUpdateZshrc(command: command)
                if !isZshrcUpdated {
                    throw SetupError.miseNotActivated(command: command.rawValue)
                } else {
                    // Force the terminal restart
                    exit(0)
                }
            } else {
                let install = promptWithDefault(message: "🔴  Mise is not installed and it's required. Would you like to install it now?")
                if install == "y" {
                    try await installMise(command: command)
                } else {
                    throw SetupError.miseNotInstalled(command: command.rawValue)
                }
            }
        }
    }

    /// Installs Mise using a shell script and updates .zshrc to activate it.
    func installMise(command: Command) async throws {
        print("🔵  Installing Mise...")
        await shell.runAndExitIfFailure("curl https://mise.jdx.dev/install.sh | sh", printOutput: false)
        _ = await verifyAndUpdateZshrc(command: command)
        exit(0)
    }

    /// Verifies if the Mise activation command is present in .zshrc and prompts to add it if missing.
    /// Returns: True/false whether the zshrc was successfully updated
    func verifyAndUpdateZshrc(command: Command) async -> Bool {
        let zshrcPath = "\(homeDirectory)/.zshrc"
        let activationCommand = "eval \"$(\(homeDirectory)/.local/bin/mise activate zsh)\""

        do {
            let zshrcContents = try String(contentsOfFile: zshrcPath, encoding: .utf8)

            if !zshrcContents.contains(activationCommand) {
                let response = promptWithDefault(message: "🔴  Mise activation command is not in `~/.zshrc`. Would you like to add it now?")
                if response == "y" {
                    appendToZshrc(command: activationCommand)
                    print("🟡  In order to finish the Mise install, please restart your Terminal and then run `./setup.swift \(command.rawValue)` again.")
                    return true
                } else {
                    printManualZshrcUpdateInstructions(command: command)
                    return false
                }
            } else {
                if !isPathUpdated() {
                    print("🟡  Mise is activated in ~/.zshrc, but the current Terminal session does not recognize it. Please restart your Terminal and then run `./setup.swift \(command.rawValue)` again.")
                    exit(0)
                }
            }
        } catch {
            print("Failed to read ~/.zshrc: \(error)")
        }
        return true
    }

    func printManualZshrcUpdateInstructions(command: Command) {
        print("Please manually add the following line to your .zshrc to activate Mise:")
        print("eval \"$(\(homeDirectory)/.local/bin/mise activate zsh)\"")
        print("After updating, please restart your Terminal and run the run `./setup.swift \(command.rawValue)` again.")
    }

    /// Appends a given command to the user's `.zshrc` file.
    func appendToZshrc(command: String) {
        let zshrcPath = "\(homeDirectory)/.zshrc"
        let fullCommand = "\n\n# Mise \n\(command)\n"

        do {
            // Check if .zshrc exists and append the command
            if FileManager.default.fileExists(atPath: zshrcPath) {
                let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: zshrcPath))
                fileHandle.seekToEndOfFile()
                if let data = fullCommand.data(using: .utf8) {
                    fileHandle.write(data)
                    fileHandle.closeFile()
                    print("🟢 ~/.zshrc was adjusted successfully.")
                }
            } else {
                // If .zshrc does not exist, create it and write the command
                try fullCommand.write(to: URL(fileURLWithPath: zshrcPath), atomically: true, encoding: .utf8)
                print(".zshrc file created and command added.")
            }
        } catch {
            print("An error occurred: \(error)")
        }
    }

    func isPathUpdated() -> Bool {
        let misePath = "\(homeDirectory)/.local/bin"
        let pathEnvironmentVariable = ProcessInfo.processInfo.environment["PATH"] ?? ""
        return pathEnvironmentVariable.split(separator: ":").contains { String($0) == misePath }
    }
}

@MainActor
final class Shell {
    private var currentTask: Process?

    // credit: https://stackoverflow.com/a/38088651
    // Shell with continuous printing to the console
    // - Returns: Shell exit code
    @discardableResult
    func run(_ command: String, printOutput: Bool = true) async -> Int32 {
        await withCheckedContinuation { continuation in
            let task = Process()
            currentTask = task

            let outpipe = Pipe()
            task.standardOutput = outpipe
            task.arguments = ["-c", command]
            task.executableURL = URL(fileURLWithPath: "/bin/zsh")
            task.standardInput = nil

            task.terminationHandler = { result in
                DispatchQueue.main.async {
                    if self.currentTask === task {
                        self.currentTask = nil
                    }
                    continuation.resume(returning: result.terminationStatus)
                }
            }

            let outputHandle = outpipe.fileHandleForReading
            outputHandle.readabilityHandler = { pipe in
                guard printOutput else { return }
                if let line = String(data: pipe.availableData, encoding: .utf8) {
                    print(line, terminator: "")
                } else {
                    print("⚠️ Error decoding data: \(pipe.availableData)")
                }
            }

            try? task.run()
        }
    }

    func terminateCurrentTask() {
        guard let task = currentTask else {
            return
        }
        task.terminate()
    }

    func runAndExitIfFailure(_ command: String, printOutput: Bool = true) async {
        let exitCode = await run(command, printOutput: printOutput)
        if exitCode != 0 {
            print("❌ Command failed with exit code \(exitCode)")
            exit(1)
        }
    }

    /// Shell with printing to the console when command terminates.
    /// Allowing prompt asking for the user password.
    func runWithPrivileges(_ command: String) async {
        let myAppleScript = "do shell script \"\(command)\""
        var error: NSDictionary?
        let scriptObject = NSAppleScript(source: myAppleScript)!
        let output = scriptObject.executeAndReturnError(&error)
        let ouputWithReplacedNewLines = (output.stringValue ?? "").replacingOccurrences(of: "\r\n", with: "\n")
        print(ouputWithReplacedNewLines)
    }
}

await Main().run()

// swiftlint:enable all
