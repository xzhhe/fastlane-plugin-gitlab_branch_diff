require 'fastlane/action'
require_relative '../helper/gitlab_branch_diff_helper'

module Fastlane
  module Actions
    module SharedValues
      GITLAB_BRANCH_DIFF_ERROR = :GITLAB_BRANCH_DIFF_ERROR
      GITLAB_BRANCH_DIFF_RESULT = :GITLAB_BRANCH_DIFF_RESULT
    end

    class GitlabBranchDiffAction < Action
      def self.run(params)
        require 'gitlab'
        projectid = params[:projectid]
        host = params[:host]
        token = params[:token]
        src = params[:src]
        dest = params[:dest]

        gc = Gitlab.client(endpoint: host, private_token: token)
        # branchs = gc.branches(projectid.to_i, {page: 1, per_page: 1024})
        # pp "⚠️ branchs:"
        # pp branchs.map { |b|
        #   b.name
        # }

        diff = gc.compare(projectid, src, dest)
        pp ' 🎉' * 30
        pp diff

        if diff.compare_timeout == true 
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GITLAB_BRANCH_DIFF_ERROR] = '❌ gitlab api timeout'
          return false
        end

        if diff.diffs.empty?
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GITLAB_BRANCH_DIFF_ERROR] = '❌ no diff'
          return false
        end

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GITLAB_BRANCH_DIFF_RESULT] = diff.diffs.map { |adif|
          adif.to_hash
        }
        true
      end

      def self.description
        "gitlab compare two branch to get diffs"
      end

      def self.authors
        ["xiongzenghui"]
      end

      def self.return_value
        "return true if success, otherwiase return false"
      end

      def self.details
        "gitlab compare two branch to get diffs"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :projectid,
            description: "gitlab project's id",
            verify_block: proc do |value|
              UI.user_error!("No projectid given, pass using `projectid: 'projectid'`") unless (value and not value.empty?)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :host,
            description: "gitlab host",
            verify_block: proc do |value|
              UI.user_error!("No gitlab host given, pass using `host: 'host'`") unless (value and not value.empty?)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :token,
            description: "gitlab token",
            verify_block: proc do |value|
              UI.user_error!("No gitlab token given, pass using `token: 'token'`") unless (value and not value.empty?)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :src,
            description: 'source branch',
            verify_block: proc do |value|
              UI.user_error!("No source branch given, pass using `src: 'src'`") unless (value and not value.empty?)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :dest,
            description: 'destination branch',
            verify_block: proc do |value|
              UI.user_error!("No destination branch given, pass using `dest: 'dest'`") unless (value and not value.empty?)
            end
          )
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
