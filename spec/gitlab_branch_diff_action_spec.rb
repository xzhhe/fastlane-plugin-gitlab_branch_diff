describe Fastlane::Actions::GitlabBranchDiffAction do
  describe '#run' do
    it 'action' do
      # expect(Fastlane::UI).to receive(:message).with("The gitlab_branch_diff plugin is working!")

      Fastlane::Actions::GitlabBranchDiffAction.run(
        projectid: '849',
        host: 'https://git.in.xxx.com/api/v4',
        token: 'xxx',
        src: 'dev',
        dest: 'master_6.11.0'
      )

      pp Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GITLAB_BRANCH_DIFF_RESULT]
    end
  end
end
