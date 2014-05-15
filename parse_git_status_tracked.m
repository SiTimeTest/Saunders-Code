function file_names = parse_git_status_tracked(message)

git_status = message;
% strings for search
modified_str = 'modified:   ';
for_commit = 'for commit:'; % to add

% find files that are modified and not yet added
add_commit_idx = strfind(git_status,modified_str);
for_commit_idx = strfind(git_status,for_commit);
if (isempty(for_commit_idx))
    file_names = [];
else
    tmp_add_idx = find(add_commit_idx > for_commit_idx);
    add_idx = add_commit_idx(tmp_add_idx);

    % track the filenames
    filename_start_idx = add_idx + length(modified_str);

    % Get the filenames to add them
    file_names = get_filenames(git_status,filename_start_idx);
end

end