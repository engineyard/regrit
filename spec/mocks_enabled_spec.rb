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

    context "(mocked timeout)" do
      before { Regrit::Provider::Mock.timeout = true }
      it { should_not be_accessible }

      it "should raise TimeoutError" do
        lambda { subject.refs }.should raise_error(Regrit::TimeoutError)
      end
    end

  end

  context "(private)" do
    # This uri would not work if we weren't mocked
    before { @uri = 'git@github.com:engineyard/regrit.git' }

    context "(mocked accessible)" do
      before { Regrit::Provider::Mock.accessible = true }

      it "would raise if I used it, but can still be requested about auth" do
        described_class.new(@uri).should be_private_key_required
      end

      it "still raises on no key" do
        lambda { described_class.new(@uri).refs }.should raise_error(Regrit::PrivateKeyRequired)
      end

      it "still raises on bad key" do
        lambda { described_class.new(@uri, :private_key => '').refs }.should raise_error(Regrit::PrivateKeyRequired)
      end

      context "with a key" do
        subject { described_class.new(@uri, :private_key => 'any key') }
        it { subject.should be_accessible }
      end
    end

    context "(mocked inaccessible)" do
      before { Regrit::Provider::Mock.accessible = false }

      it "would raise if I used it, but can still be requested about auth" do
        described_class.new(@uri).should be_private_key_required
      end

      it "still raises on bad key" do
        lambda { described_class.new(@uri).refs }.should raise_error(Regrit::PrivateKeyRequired)
        lambda { described_class.new(@uri, :private_key => '').refs }.should raise_error(Regrit::PrivateKeyRequired)
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

    it "returns nil if no ref matches" do
      subject.ref('thisdoesntexist').should be_nil
    end

    context "(setting the response)" do
      before do
        Regrit::Provider::Mock.refs = <<-REFS
1234567890123456789012345678901234567890\tHEAD
1234567890123456789012345678901234567890\trefs/heads/master
1234567890123456789012345678901234567890\trefs/tags/v1.2.3
        REFS
      end

      it "returns the refs as set" do
        subject.should have(3).refs
        subject.ref('master').abbrev_commit.should == "1234567"
        subject.ref('master').should be_branch
        subject.refs.first.name.should == "HEAD"
        subject.refs.first.type.should == nil
        subject.ref('v1.2.3').type.should == 'tags'
        subject.ref('v1.2.3').should be_tag
        subject.ref('v1.2.3').should_not be_branch
      end
    end
  end
end
