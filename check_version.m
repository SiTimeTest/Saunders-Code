runinfo.operator = 'JY';
runinfo.comments = 'test automated script';
% check if files are modified and not up to date

diff_result = git('diff');
if isempty(diff_result)
    fprintf('current version is up to date\n\n');
    need_to_update = 0;
else
    fprintf('current version is NOT up to date\n\n');
    need_to_update = 1;
end

% parse git status message
git_status = git('status');
on_branch_str = 'On branch ';
on_branch_idx = strfind(git_status,on_branch_str);
branch_start_idx = on_branch_idx + length(on_branch_str);
branch_end_idx_tmp = find(git_status((on_branch_idx + length(on_branch_str)):end) == sprintf('\n'));
branch_end_idx = branch_start_idx + branch_end_idx_tmp(1) - 2;

% switch to the operator's branch
fprintf('Checking out to branch ''%s'' ...',runinfo.operator);
result = git(['checkout -b ',runinfo.operator]);
if strcmp(result(1:5),'fatal')
%     fprintf('Branch already exists\n\n');
    result = git(['checkout ',runinfo.operator]);
else
%     fprintf('On branch %s\n\n',runinfo.operator);
end
fprintf('done!\n');

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
        modified_filenames = cell(size(filename_start_idx));
        modified_N = length(filename_start_idx);

        for i = 1:modified_N
            if i == modified_N
                tmp_str = git_status(filename_start_idx(i):end);
            else
                tmp_str = git_status(filename_start_idx(i):filename_start_idx(i+1));
            end
            tmp_filename_end_idx = find(tmp_str == sprintf('\n'));
            filename_end_idx(i) = tmp_filename_end_idx(1) - 1;
            modified_filenames{i} = tmp_str(1:filename_end_idx(i));
            fprintf('adding file "%s" ...',modified_filenames{i});
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
            untracked_filenames = cell(size(filename_start_idx));
            modified_N = length(filename_start_idx);

            for i = 1:modified_N
                % parse the filename strings
                if i == modified_N
                    tmp_str = git_status(filename_start_idx(i):end);
                else
                    tmp_str = git_status(filename_start_idx(i):filename_start_idx(i+1));
                end
                
                tmp_filename_end_idx = find(tmp_str == sprintf('\n'));
                filename_end_idx(i) = tmp_filename_end_idx(1) - 1;
                untracked_filenames{i} = tmp_str(1:filename_end_idx(i));
                tmp_untracked_filename = untracked_filenames{i};
                file_format = tmp_untracked_filename((find(tmp_untracked_filename == '.')+1):end);

                if (strcmp(file_format,'m'))
                    fprintf('adding file "%s"...',untracked_filenames{i});
                    result = git(sprintf('add %s',untracked_filenames{i}));
                    fprintf('done!\n\n');
                else
                    fprintf('File format ''.%s'' is not needed to be tracked\n\n',file_format);
                end
            end
        end
    end

    fprintf('commit now...\n\n');
    result = git(sprintf('commit -m "%s %s"\n\n',runinfo.comments,datestr(now,'yymmddHHMMSS')));
end


% parse the result message into three parts:
% 1. M - filename
% 2. Untracked files - filename
% 3. others