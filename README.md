# Regrit

Regrit provides an interface for remote repository. This gem is used by awsm to load remote refs and check deploy key installation.

## Usage

    @repo ||= Regrit::RemoteRepo.new(repository_uri, :private_key => deploy_key_private)

    if repo.private_key_required?
      puts "this repo will require a deploy key to retrieve any information"
    end

    if repo.accessible?
      puts "repo is accessible"
    end

    ref_list =
      begin
        repo.refs
      rescue Regrit::Inaccessible
        []
      end

    commit_sha =
      begin
        repo.ref('master')
      rescue Regrit::Inaccessible
        nil
      end

