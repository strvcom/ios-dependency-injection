# By Jakub Kaspar 10/30/2018
# STRV s.r.o. 2018
# STRV

# Sometimes its a README fix, or something like that - which isn't relevant for including in a CHANGELOG for example
declared_trivial = github.pr_title.include?("#trivial") || github.pr_title.include?("[WIP]") || github.pr_body.include?("#trivial")

# Uncomment following lines if you want to enforce CHANGELOG updates
# if git.lines_of_code > 50 && !git.modified_files.include?("CHANGELOG.md") && !git.added_files.include?("CHANGELOG.md") && !declared_trivial
#     fail("No CHANGELOG changes made")
# end

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Mainly to encourage writing up some reasoning about the PR, rather than just leaving a title
if github.pr_body.length < 5
    fail("Please provide a summary in the Pull Request description")
end

# Warn when there is a big PR
if git.lines_of_code > 1000
    warn("Big PR - you should create smaller!")
end

# By default we have SwiftLint in our vendor folder. 

# Projects with SwiftLint via SPM plugin without using mise
#
# If you are using Swiftlint with SPM (for some reason) you must omit the `swiftlint.binary_path` (eg. delete the lines 35-42)
# Also be sure to specify the correct version in `.swiftlint-version` file
# and you must have the `Set SwiftLint version` step in the integrations GitHub Action
# by doing that "Danger Swiftlint" will install the desired version itself

# Determine the SwiftLint binary path dynamically using mise
swiftlint_binary_path = `mise which swiftlint`.strip
# Set SwiftLint binary path if found
if swiftlint_binary_path.empty?
    warn("SwiftLint binary not found, using default path")
else
    swiftlint.binary_path = swiftlint_binary_path
end

swiftlint.config_file = '.github/config/.swiftlint.yml'
swiftlint.lint_files inline_mode:true, fail_on_error:true

duplicate_localizable_strings.check_localizable_duplicates

# Determine the SwiftFormat binary path dynamically using mise
swiftformat_binary_path = `mise which swiftformat`.strip
# Set SwiftFormat binary path if found
if swiftformat_binary_path.empty?
    warn("SwiftFormat binary not found, using default path")
else
    swiftformat.binary_path = swiftformat_binary_path
end
# Runs SwiftFormat on changed files
swiftformat.check_format(fail_on_error: true)