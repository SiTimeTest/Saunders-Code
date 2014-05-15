runinfo.operator = 'JZ';  
runinfo.comments = 'test automated script';

local_backup_path = 'C:\Users\jinzey\Documents\Saunder''s Code Version Control\';

% parse git status message
git_status = git('status');

% Find out which branch the version is currently on
current_branch = get_curr_branch(git_status);

if (strcmp(current_branch,runinfo.operator))
    fprintf('The current branch is the operator''s branch!\n');
else
    % switch to the operator's branch
    fprintf('Checking out to branch ''%s'' ... \n',runinfo.operator);
    result_checkout_b = git(['checkout -b ',runinfo.operator]);
    if strcmp(result_checkout_b(1:5),'fatal')
    %     fprintf('Branch already exists\n\n');
        result_checkout = git(['checkout ',runinfo.operator]);

        if (strcmp(result_checkout(1:5),'error'))
            fprintf('Local changes exists, need to back up first\n');
            % back up the modified files into a local backup folder, then
            % 'stash', then switch to the operator's branch, then copy the
            % files back, and delete them in the backup path
            by_checkout = 'by checkout:';
            please_commit = 'Please, commit';
            by_checkout_idx = strfind(result_checkout,by_checkout);
            please_commit_idx = strfind(result_checkout,please_commit);
            tab_idx = find(result_checkout==sprintf('\t')); % to locate where are the tabs
            tab_for_local_change_idx = find(tab_idx > by_checkout_idx & tab_idx < please_commit_idx);

            filename_start_idx = tab_idx(tab_for_local_change_idx)+1;
            local_filenames = get_filenames(result_checkout,filename_start_idx);
            filepath = cell(length(filename_start_idx));
            for i = 1:length(filename_start_idx)
                fprintf('backing up file ''%s'' ... ',local_filenames{i});
                filepath{i} = which(local_filenames{i});
                copyfile(filepath{i},sprintf('%s%s',local_backup_path,local_filenames{i}));
                fprintf('done!\n');
            end
            fprintf('stash the local changes ... ');
            git('stash');
            fprintf('done!\n');
            fprintf('check out to branch ''%s'' ... ', runinfo.operator);
            result_checkout = git(['checkout ',runinfo.operator]);
            fprintf('done!\n');
            fprintf('restore these files from local backup ... \n');

            for i = 1:length(filename_start_idx)
                fprintf('restoring file ''%s'' ... ',local_filenames{i});
                copyfile(sprintf('%s%s',local_backup_path,local_filenames{i}),filepath{i});
                fprintf('done!\n');
            end

            fprintf('restorage is done!\n');

        end

    else
    %     fprintf('On branch %s\n\n',runinfo.operator);
    end
    fprintf('checking out to branch %s is done!\n\n',runinfo.operator);
end

% check if files are modified and not up to date

diff_result = git('diff');
if isempty(diff_result)
    fprintf('current version is up to date\n\n');
    need_to_update = 0;
else
    fprintf('current version is NOT up to date\n\n');
    need_to_update = 1;
end


if (need_to_update)

    fprintf('The current branch needs to update\n\n');
    
    % parse git status message
    git_status = git('status');

    % strings for search
    modified_str = 'modified:   ';
    committed = 'committed:'; % to commit
    for_commit = 'for commit:'; % to add
    untracked_files_str = 'Untracked files:'; % to add, or NOT, check if '.m' or not
    untracked_to_add = 'include in what will be committed)';

    % find files that are modified and not yet added
    add_commit_idx = strfind(git_status,modified_str);
    for_commit_idx = strfind(git_status,for_commit);
    if (isempty(for_commit_idx))
        fprintf('Modified files are all to be committed\n\n');
    else
        fprintf('Some files are modified and needed to be added before commit\n\n');
        tmp_add_idx = find(add_commit_idx > for_commit_idx);
        add_idx = add_commit_idx(tmp_add_idx);

        % track the filenames
        filename_start_idx = add_idx + length(modified_str);
        filename_end_idx = zeros(size(filename_start_idx));

        % Get the filenames to add them
        modified_filenames = get_filenames(git_status,filename_start_idx);
        modified_N = length(filename_start_idx);
        % Add files
        for i = 1:modified_N
            fprintf('adding file ''%s'' ... ',modified_filenames{i});
            result = git(sprintf('add %s',modified_filenames{i}));
            fprintf('done!\n\n');
        end
    end

    % Up to now, files that are modified, are all added, and need to commit
    % Next step will be check if the 'Untracked files' are necessary to add

    untracked_idx = strfind(git_status,untracked_files_str);
    if (isempty(untracked_idx))
        fprintf('No untracked files, ready to commit\n\n');
    else
        fprintf('Untracked files exist\n\n');
        untracked_to_add_idx = strfind(git_status,untracked_to_add);
        tab_idx = find(git_status==sprintf('\t')); % to locate where are the tabs
        tab_for_untracked_idx = find(tab_idx > untracked_to_add_idx);
        if isempty(tab_for_untracked_idx)
            % this case does not exist
        else
            filename_start_idx = tab_idx(tab_for_untracked_idx)+1;
            filename_end_idx = zeros(size(filename_start_idx));

            % Get the filenames, check the format, then add them
            untracked_filenames = get_filenames(git_status,filename_start_idx);
            untracked_N = length(filename_start_idx);

            for i = 1:untracked_N
                tmp_untracked_filename = untracked_filenames{i};
                file_format = tmp_untracked_filename((find(tmp_untracked_filename == '.')+1):end);
                % Select the files with right format to add.
                if (strcmp(file_format,'m'))
                    fprintf('adding file ''%s'' ... ',untracked_filenames{i});
                    result = git(sprintf('add %s',untracked_filenames{i}));
                    fprintf('done!\n\n');
                else
                    fprintf('File format ''.%s'' is not needed to be tracked\n\n',file_format);
                end
            end
        end
    end

    fprintf('commit now ... ');
    result = git(sprintf('commit -m "%s %s"\n\n',runinfo.comments,datestr(now,'yymmddHHMMSS')));
    fprintf('done!\n');
end


% parse the result message into three parts:
% 1. M - filename
% 2. Untracked files - filename
% 3. others