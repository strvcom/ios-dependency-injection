#!/usr/bin/swift
import Foundation

// swiftlint:disable disable_print

// This enables the script to exit when the user presses Ctrl+C
signal(SIGINT) { _ in exit(0) }

// MARK: - Enums

enum LayerType: String, CaseIterable {
    case feature = "Feature"
    case service = "Service"
    case library = "Library"
}

enum ModuleGenerationError: Error {
    case failedToReadDependencyFile
    case failedToWriteDependencyFile
    case invalidInsertionPoint
    case failedToReadTuistOutput
}

// MARK: - Structs

struct ModuleInfo {
    let layer: LayerType
    let moduleName: String
    let hasInterface: Bool
    let hasTestResources: Bool
    let hasUnitTests: Bool
    let hasUITests: Bool
    let hasExample: Bool
    let hasLocalizedStrings: Bool
    let hasAssets: Bool
}

// MARK: - Module Generator

/// This class utilizes Tuist's `scaffold` command to generate the basic structure and files
/// for new modules in a modularized project. It automates the process of creating modules,
/// their interfaces, tests, and example targets based on provided specifications.
final class ModuleGenerator {
    private let fileManager = FileManager.default
    private let currentPath = "./"

    func generateModule() {
        do {
            let moduleInfo = getModuleInfo()
            try scaffoldModule(moduleInfo)
            try registerDependency(moduleInfo)

            let createdTargets = listCreatedTargets(moduleInfo)
            print("✅ Module '\(moduleInfo.moduleName)' created successfully in the \(moduleInfo.layer.rawValue) layer!")
            print("   Created targets: \(createdTargets)")
        } catch {
            print("❌ Error creating module: \(error)")
        }
    }
}

private extension ModuleGenerator {
    func getModuleInfo() -> ModuleInfo {
        print("\u{001B}[1mWhat's the layer of this module?\u{001B}[0m")
        for (index, layer) in LayerType.allCases.enumerated() {
            print("\(index + 1). \(layer.rawValue)")
        }

        let layer = LayerType.allCases[getIntInput(min: 1, max: LayerType.allCases.count) - 1]

        print("\u{001B}[1mEnter module name:\u{001B}[0m", terminator: " ")
        let moduleName = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let hasResources = getBoolInput("Do you want to include resources (strings or assets) in this module?")
        var hasLocalizedStrings = false
        var hasAssets = false

        if hasResources {
            hasLocalizedStrings = getBoolInput("Do you want to include localized strings?")
            hasAssets = getBoolInput("Do you want to include an Asset catalog (for colors and images)?")
        }

        let hasInterface = getBoolInput("Do you want to include an Interface target?")
        let hasUnitTests = getBoolInput("Do you want to include unit tests target?")
        let hasUITests = getBoolInput("Do you want to include UI tests target?")
        let hasTestResources = if hasUnitTests || hasUITests {
            getBoolInput("Do you need a TestResources target for test utilities and mocks?")
        } else {
            false
        }

        let hasExample = hasUITests || getBoolInput("Do you want to create an Example target (for a demo app)?")

        print("\u{001B}[1m⏳ Generating...:\u{001B}[0m\n\n", terminator: " ")

        return ModuleInfo(
            layer: layer,
            moduleName: moduleName,
            hasInterface: hasInterface,
            hasTestResources: hasTestResources,
            hasUnitTests: hasUnitTests,
            hasUITests: hasUITests,
            hasExample: hasExample,
            hasLocalizedStrings: hasLocalizedStrings,
            hasAssets: hasAssets
        )
    }

    func scaffoldModule(_ moduleInfo: ModuleInfo) throws {
        try scaffoldMainModule(moduleInfo)

        if moduleInfo.hasInterface { try scaffoldInterface(moduleInfo) }
        if moduleInfo.hasTestResources { try scaffoldTestResources(moduleInfo) }
        if moduleInfo.hasUnitTests { try scaffoldTests(moduleInfo) }
        if moduleInfo.hasUITests { try scaffoldUITests(moduleInfo) }
        if moduleInfo.hasExample { try scaffoldExample(moduleInfo) }
        if moduleInfo.hasLocalizedStrings { try scaffoldLocalizedStrings(moduleInfo) }
        if moduleInfo.hasAssets { try scaffoldAssets(moduleInfo) }
    }

    func scaffoldMainModule(_ moduleInfo: ModuleInfo) throws {
        let args = [
            "scaffold",
            "Module",
            "--layer", moduleInfo.layer.rawValue,
            "--name", moduleInfo.moduleName,
            "--interface", moduleInfo.hasInterface.description,
            "--testresources", moduleInfo.hasTestResources.description,
            "--tests", moduleInfo.hasUnitTests.description,
            "--uitests", moduleInfo.hasUITests.description,
            "--example", moduleInfo.hasExample.description,
            "--localizedstrings", moduleInfo.hasLocalizedStrings.description,
            "--assets", moduleInfo.hasAssets.description,
        ]

        try runTuistCommand(args)
    }

    func scaffoldInterface(_ moduleInfo: ModuleInfo) throws {
        let args = [
            "scaffold",
            "Interface",
            "--layer", moduleInfo.layer.rawValue,
            "--name", moduleInfo.moduleName,
        ]

        try runTuistCommand(args)
    }

    func scaffoldTestResources(_ moduleInfo: ModuleInfo) throws {
        let args = [
            "scaffold",
            "TestResources",
            "--layer", moduleInfo.layer.rawValue,
            "--name", moduleInfo.moduleName,
        ]

        try runTuistCommand(args)
    }

    func scaffoldTests(_ moduleInfo: ModuleInfo) throws {
        let args = [
            "scaffold",
            "Tests",
            "--layer", moduleInfo.layer.rawValue,
            "--name", moduleInfo.moduleName,
        ]

        try runTuistCommand(args)
    }

    func scaffoldUITests(_ moduleInfo: ModuleInfo) throws {
        let args = [
            "scaffold",
            "UITests",
            "--layer", moduleInfo.layer.rawValue,
            "--name", moduleInfo.moduleName,
        ]

        try runTuistCommand(args)
    }

    func scaffoldExample(_ moduleInfo: ModuleInfo) throws {
        let args = [
            "scaffold",
            "Example",
            "--layer", moduleInfo.layer.rawValue,
            "--name", moduleInfo.moduleName,
        ]

        try runTuistCommand(args)
    }

    func scaffoldLocalizedStrings(_ moduleInfo: ModuleInfo) throws {
        let args = [
            "scaffold",
            "Localizable",
            "--layer", moduleInfo.layer.rawValue,
            "--name", moduleInfo.moduleName,
        ]

        try runTuistCommand(args)
    }

    func scaffoldAssets(_ moduleInfo: ModuleInfo) throws {
        let args = [
            "scaffold",
            "Assets",
            "--layer", moduleInfo.layer.rawValue,
            "--name", moduleInfo.moduleName,
        ]

        try runTuistCommand(args)
    }

    func registerDependency(_ moduleInfo: ModuleInfo) throws {
        let dependencyFilePath = "\(currentPath)Tuist/ProjectDescriptionHelpers/Dependencies/Dependency+Module.swift"

        guard var content = try? String(contentsOfFile: dependencyFilePath, encoding: .utf8) else {
            throw ModuleGenerationError.failedToReadDependencyFile
        }

        let newDependencies = createDependencyDeclarations(for: moduleInfo)

        guard let range = content.range(of: "public extension TargetDependency.Module.\(moduleInfo.layer.rawValue) {") else {
            throw ModuleGenerationError.invalidInsertionPoint
        }

        let insertionPoint = content.index(after: range.upperBound)
        content.insert(contentsOf: "    \(newDependencies.joined(separator: "\n    "))\n", at: insertionPoint)

        let formattedContent = formatDependencyExtension(content, for: moduleInfo.layer)

        do {
            try formattedContent.write(toFile: dependencyFilePath, atomically: true, encoding: .utf8)
            print("✅ Dependency added to Dependency+Module.swift")
        } catch {
            throw ModuleGenerationError.failedToWriteDependencyFile
        }
    }

    func createDependencyDeclarations(for moduleInfo: ModuleInfo) -> [String] {
        let moduleLowercaseName = moduleInfo.moduleName.prefix(1).lowercased() + moduleInfo.moduleName.dropFirst()
        var declarations = [
            "static let \(moduleLowercaseName) = TargetDependency.\(moduleInfo.layer.rawValue.lowercased())(name: \"\(moduleInfo.moduleName)\")",
        ]

        if moduleInfo.hasInterface {
            declarations.append(
                "static let \(moduleLowercaseName)Interface = TargetDependency.\(moduleInfo.layer.rawValue.lowercased())(name: \"\(moduleInfo.moduleName)\", targetType: .interface)"
            )
        }

        if moduleInfo.hasTestResources {
            declarations.append(
                "static let \(moduleLowercaseName)TestResources = TargetDependency.\(moduleInfo.layer.rawValue.lowercased())(name: \"\(moduleInfo.moduleName)\", targetType: .testResources)"
            )
        }

        return declarations
    }

    /// Formats the dependency extension in the Dependency+Module.swift file.
    ///
    /// This method is responsible for organizing and formatting the dependency declarations
    /// within a specific layer's extension in the Dependency+Module.swift file. It performs
    /// the following tasks:
    ///
    /// 1. Identifies the correct extension block for the given layer.
    /// 2. Sorts the dependency declarations alphabetically within the extension.
    /// 3. Ensures proper indentation and spacing of the declarations.
    func formatDependencyExtension(_ content: String, for layer: LayerType) -> String {
        let lines = content.components(separatedBy: .newlines)
        var formattedLines: [String] = []
        var inTargetExtension = false
        var extensionLines: [String] = []
        var commentLine: String?
        var emptyLineAdded = false

        for line in lines {
            if line.contains("public extension TargetDependency.Module.\(layer.rawValue)") {
                inTargetExtension = true
                formattedLines.append(line)
            } else if inTargetExtension {
                if line.contains("}") {
                    // Add comment and empty line if they exist
                    if let comment = commentLine {
                        formattedLines.append("    " + comment)
                    }
                    if !emptyLineAdded {
                        formattedLines.append("")
                    }
                    // Sort and format the extension lines
                    extensionLines.sort()
                    formattedLines.append(contentsOf: extensionLines.map { "    \($0)" })
                    formattedLines.append("}")
                    inTargetExtension = false
                } else if line.trimmingCharacters(in: .whitespaces).starts(with: "//") {
                    commentLine = line.trimmingCharacters(in: .whitespaces)
                } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                    emptyLineAdded = true
                } else if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                    // Split multiple declarations on the same line
                    let declarations = line.components(separatedBy: "static let")
                        .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                        .map { "static let " + $0.trimmingCharacters(in: .whitespaces) }
                    extensionLines.append(contentsOf: declarations)
                }
            } else {
                formattedLines.append(line)
            }
        }

        return formattedLines.joined(separator: "\n")
    }

    func listCreatedTargets(_ moduleInfo: ModuleInfo) -> String {
        var targets = [moduleInfo.moduleName]

        if moduleInfo.hasInterface {
            targets.append("\(moduleInfo.moduleName)Interface")
        }
        if moduleInfo.hasTestResources {
            targets.append("\(moduleInfo.moduleName)TestResources")
        }
        if moduleInfo.hasUnitTests {
            targets.append("\(moduleInfo.moduleName)Tests")
        }
        if moduleInfo.hasUITests {
            targets.append("\(moduleInfo.moduleName)UITests")
        }
        if moduleInfo.hasExample {
            targets.append("\(moduleInfo.moduleName)Example")
        }

        return targets.joined(separator: ", ")
    }

    func runTuistCommand(_ args: [String]) throws {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["tuist"] + args

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else {
                throw ModuleGenerationError.failedToReadTuistOutput
            }
            print(output)

            if process.terminationStatus != 0 {
                throw NSError(
                    domain: "TuistError",
                    code: Int(process.terminationStatus),
                    userInfo: [NSLocalizedDescriptionKey: "Tuist command failed"]
                )
            }
        } catch {
            print("Failed to run Tuist command: \(error)")
            throw error
        }
    }

    func getIntInput(min: Int, max: Int) -> Int {
        while true {
            print("\u{001B}[1mEnter a number between \(min) and \(max):\u{001B}[0m", terminator: " ")
            if let input = readLine(), let number = Int(input), number >= min, number <= max {
                return number
            }
            print("Invalid input. Please try again.")
        }
    }

    func getBoolInput(_ question: String) -> Bool {
        while true {
            print("\u{001B}[1m\(question)\u{001B}[0m (y/n):", terminator: " ")
            if let input = readLine()?.lowercased() {
                switch input {
                case "y", "yes":
                    return true
                case "n", "no":
                    return false
                default:
                    break
                }
            }
            print("Invalid input. Please enter 'y' or 'n'.")
        }
    }
}

// swiftlint:enable disable_print

// MARK: - Main Execution

let moduleGenerator = ModuleGenerator()
moduleGenerator.generateModule()
