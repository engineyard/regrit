require 'spec_helper'

describe Regrit::RemoteRepo do

  context "(invalid uri)" do
    [
      'http://',
      'git://user@host.com/repo/here.git', # not valid according to docs
      nil, ""
    ].each do |uri|
      it "raises on initialization with #{uri.inspect}" do
        lambda { described_class.new(uri) }.should raise_error(Regrit::InvalidURIError)
      end
    end
  end

  context "(valid uri)" do
    [
      # valid host names as described by git documentation
      'rsync://host.xz/path/to/repo.git/',
      'ftps://host.xz/path/to/repo.git/',
      'ftp://host.xz/path/to/repo.git/',
      'http://host.xz/path/to/repo.git/',
      'https://host.xz/path/to/repo.git/',
      'git://host.xz/path/to/repo.git',
      'git://host.xz:8888/path/to/repo.git/',
      'git://host.xz/~user/path/to/repo.git',
      'git://host.xz:8888/~user/path/to/repo.git/',
      'git://11.22.33.44/~user/path/to/repo.git',
      'git://12.34.56.78:8888/~user/path/to/repo.git/',
      'ssh://user@11.22.33.44/path/to/repo.git/',
      'ssh://user@111.222.333.444:8888/path/to/repo.git',
      'ssh://user@host.xz:8888/path/to/repo.git',
      'ssh://user@host.xz/path/to/repo.git/',
      'ssh://user@host.xz/~user/path/to/repo.git/',
      'ssh://user@host.xz/~/path/to/repo.git',
      'user@host.xz:/path/to/repo.git',
      'user@123.123.123.123:/path/to/repo.git',
      'user@host.xz:~user/path/to/repo.git/',
      'user@1.0.0.0:~user/path/to/repo.git/',
      'user@host.xz:path/to/repo.git',
    ].each do |uri|
      it "creates a Regrit::RemoteRepo with #{uri.inspect}" do
        described_class.new(uri, :private_key => private_key).should be_a_kind_of(described_class)
      end
    end
  end

  # These specs could be a bit more brittle because they access public repositories
  describe "accessing" do
    context "(non-resolving)" do
      subject { described_class.new("git://example.com/non-resolve.git") }

      it "doesn't hang when trying to access a bad server name" do
        should_not be_accessible
      end
    end

    context "(non-existant)" do
      subject { described_class.new("git://github.com/engineyard/this_project_will_never_exist_and_if_it_does_then_this_will_break.git") }

      it { should_not be_private_key_required }
      it { should_not be_accessible }
    end

    context "(public)" do
      subject { described_class.new("git://github.com/rails/rails.git") }

      it { should_not be_private_key_required }
      it { should be_accessible }
    end

    context "(private)" do
      before { @uri = "git@github.com:martinemde/regrit.git" }
      subject { described_class.new(@uri, :private_key => private_key) }

      it { should be_private_key_required }
      it { should be_accessible }

      describe "loading refs" do
        it { should have_at_least(2).refs }

        it "has a master ref" do
          subject.ref('master').name.should == 'refs/heads/master'
        end
      end

      it "raises on initialization without a key" do
        lambda { described_class.new(@uri) }.should raise_error(Regrit::PrivateKeyRequired)
      end

      it "raises on initialization with an empty key" do
        lambda { described_class.new(@uri, :private_key => '') }.should raise_error(Regrit::PrivateKeyRequired)
      end

      context "with wrong key" do
        subject { described_class.new(@uri, :private_key => wrong_private_key) }
        it { should_not be_accessible }
        it "raises a CommandError on trying to access refs" do
          lambda { subject.refs }.should raise_error(Regrit::CommandError)
        end
      end
    end
  end
end
