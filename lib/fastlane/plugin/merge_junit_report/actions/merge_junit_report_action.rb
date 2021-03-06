module Fastlane
  module Actions
    class MergeJunitReportAction < Action
      UI = FastlaneCore::UI

      def self.run(params)
        FastlaneCore::PrintTable.print_values(
          config: params,
          title: 'Summary for merge_junit_report Action'
        )
        input_files = params[:input_files]

        xml_docs = input_files.map { |file| REXML::Document.new(File.new(file)) }
        merger = Fastlane::Plugin::MergeJunitReport::Merger.new(xml_docs)
        merged = merger.merge

        # write to output_file
        output_file = File.absolute_path(params[:output_file])
        FileUtils.mkdir_p(File.dirname(output_file))
        File.open(output_file, 'w') { |f| merged.write(f, 2) }
        UI.success("Reports merged to #{output_file} successfully")
      end

      def self.description
        'Provides the ability to merge multiple junit reports into one'
      end

      def self.authors
        ['Derek Yang']
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :input_files,
                                       env_name: 'MERGE_JUNIT_REPORT_INPUT_FILES',
                                       description: 'A list of junit report files to merge from',
                                       optional: false,
                                       type: Array,
                                       verify_block: proc do |input_files|
                                                       UI.user_error!('No input files!') if input_files.empty?
                                                       input_files.each do |input_file|
                                                         UI.user_error!("File not found: #{input_file}") unless File.file?(input_file)
                                                       end
                                                     end),
          FastlaneCore::ConfigItem.new(key: :output_file,
                                       env_name: 'MERGE_JUNIT_REPORT_OUTPUT_FILE',
                                       description: 'The output file where all input files will be merged into',
                                       optional: true,
                                       default_value: 'result.xml',
                                       type: String)
        ]
      end

      def self.example_code
        [
          'merge_junit_report(
            input_files: ["report1.xml", "report2.xml"],
            output_file: "output/merged_report.xml"
          )'
        ]
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
