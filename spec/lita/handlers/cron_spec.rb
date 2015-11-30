require 'spec_helper'

describe Lita::Handlers::Cron, lita_handler: true do
  it { is_expected.to route_command('cron list').to(:list) }
  it { is_expected.to route_command('cron new 15 15 * * * rspec_test_job').to(:new) }
  it { is_expected.to route_command('cron delete rspec_test_job').to(:delete) }

  describe '#cron list' do
    it "replies to the 'cron list' command" do
      send_command('cron list')
      expect(replies.last).to eq('No cron jobs currently running.')
    end

    it "replies to the 'cron list' command with results" do
      send_command('cron new 15 15 * * * rspec_test_job')

      send_command('cron list')
      expect(replies.last).to eq('rspec_test_job=>["15 15 * * *"]')
    end
  end

  describe '#cron delete doesnotexist' do
    it 'handles non-existant cron job, replying with status' do
      send_command('cron delete doesnotexist')
      expect(replies.last).to eq("doesnotexist isn't an existing cron job.")
    end
  end

  describe '#cron new 15 15 * * * rspec_test_job' do
    before { subject.redis.flushdb }
    it 'creates a new cron job, replying with status' do
      send_command('cron new 15 15 * * * rspec_test_job')
      expect(replies.first).to eq('New cron job: 15 15 * * * rspec_test_job')
    end
  end

  describe '#cron delete rspec_test_job' do
    it 'deletes a cron job, replying with status' do
      send_command('cron new 15 15 * * * rspec_test_job')
      send_command('cron delete rspec_test_job')
      expect(replies).to include('Deleted rspec_test_job.')
    end
  end
end
