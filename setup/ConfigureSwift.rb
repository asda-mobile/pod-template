module Pod

  class ConfigureSwift
    attr_reader :configurator

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @configurator = options.fetch(:configurator)
    end

    def perform
      keep_demo = configurator.ask_with_answers("Would you like to include a demo application with your library", ["No", "Yes"]).to_sym

      # Set XCTest framework
      configurator.set_test_framework "xctest", "swift", "swift"

      ui_tests = configurator.ask_with_answers("Would you like to do view based testing", ["No", "Yes"]).to_sym
      case ui_tests
        when :yes
          if keep_demo == :no
              puts " Putting demo application back in, you cannot do view tests without a host application."
              keep_demo = :yes
          end
      end

      create_git = configurator.ask_with_answers("Would you like to create a new git repo?", ["No", "Yes"]).to_sym

      Pod::ProjectManipulator.new({
        :configurator => @configurator,
        :xcodeproj_path => "templates/swift/PROJECT.xcodeproj",
        :demo_xcodeproj_path => "templates/swift/Example/PROJECT-Example.xcodeproj",
        :platform => :ios,
        :remove_demo_project => (keep_demo == :no),
        :prefix => "",
        :create_git => (create_git == :yes)
      }).run

      `mv ./templates/swift/* ./`

      # The Podspec should be 11.0 instead of 7.0
      text = File.read("NAME.podspec")
      text.gsub!("7.0", "11.0")
      File.open("NAME.podspec", "w") { |file| file.puts text }

      # remove podspec for osx
      `rm ./NAME-osx.podspec`
    end
  end

end
