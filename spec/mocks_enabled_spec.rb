require 'spec_helper'

describe Regrit::RemoteRepo do
  before { Regrit.enable_mock! }
  after { Regrit.disable_mock! }

  before { @uri = 'git://example.com/does/not/work.git' }

  context "(public)" do
    # This uri would not work if we weren't mocked
    subject { described_class.new(@uri) }

    it { should_not be_private_key_required }

    context "(mocked accessible)" do
      before { Regrit::Provider::Mock.accessible = true }
      it { should be_accessible }
    end

    context "(mocked inaccessible)" do
      before { Regrit::Provider::Mock.accessible = false }
      it { should_not be_accessible }
    end
  end

  context "(private)" do
    # This uri would not work if we weren't mocked

    context "(mocked accessible)" do
      before { Regrit::Provider::Mock.accessible = true }

      it "still raises on bad key" do
        pending("should we care if the key is blank in mock mode?") do
          lambda { described_class.new(@uri, :private_key => '') }.should raise_error
        end
      end

      context "with a key" do
        subject { described_class.new(@uri, :private_key => 'any key') }
        it { subject.should be_accessible }
      end
    end

    context "(mocked inaccessible)" do
      before { Regrit::Provider::Mock.accessible = false }

      it "still raises on bad key" do
        pending("should we care if the key is blank in mock mode?") do
          lambda { described_class.new(@uri, :private_key => '') }.should raise_error
        end
      end

      context "with a key" do
        subject { described_class.new(@uri, :private_key => private_key) }
        it { subject.should_not be_accessible }
      end
    end
  end

  context "(refs)" do
    subject { described_class.new(@uri) }

    it "returns default refs" do
      subject.should have(2).refs
      subject.ref('master').abbrev_commit.should == "1234567"
      subject.refs.first.name.should == "HEAD"
    end

    context "(setting the response)" do
      before do
        Regrit::Provider::Mock.refs = <<-REFS
1234567890123456789012345678901234567890\tHEAD
1234567890123456789012345678901234567890\trefs/heads/master
        REFS
      end

      it "returns the refs as set" do
        subject.should have(2).refs
        subject.ref('master').abbrev_commit.should == "1234567"
        subject.refs.first.name.should == "HEAD"
      end
    end
  end
end
