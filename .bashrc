alias gl='git log --graph --abbrev-commit --decorate --date=relative --format=format:"%C(auto)%h%d %s %C(black)%C(bold)%cr"' # Show commits
alias dev='git checkout dev' # Switches to dev
alias main='git checkout main' # Switches to main
alias back='git checkout -' # Switches to previous branch
alias push='git push'
alias pfwl='git push --force-with-lease' # Does a force-with-lease push (Useful when using rebasing)
alias pull='git pull'
alias plr='git pull --rebase'
alias status='git status'
alias pop='git stash pop'
alias branch='git branch'
alias list='git stash list'
alias setrc='source ~/.bashrc'
alias editrc='vim ~/.bashrc'

# Does interactive rebase on default branch
rebasi() {
	default_branch_name=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's/origin\///')
	git rebase -i $default_branch_name
}

# Sets upstream in GitHub for whatever your current branch is
# Use this the first time you push your branch up
pushnew() {
	current_branch=$(git branch --show-current)
	echo -e "\e[1;35mSetting upstream and pushing $current_branch to origin...\e[0m"
	git push -u origin $current_branch --quiet
}
########

# Creates and switches to a new branch off of your default branch, no matter what branch is currently checked out
# Takes 1 argument: New Branch Name (example: `new myNewBranch`)
new() {
	default_branch_name=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's/origin\///')

	echo -e "\e[1;35mSwitching to $default_branch_name...\e[0m"
	git checkout $default_branch_name

	echo -e "\e[1;35mPulling latest for $default_branch_name...\e[0m"
	git pull

	echo -e "\e[1;35mCreating and switching to $1 from $default_branch_name...\e[0m"
	git checkout -b $1 $default_branch_name --quiet
}
########

# Deletes all local branches EXCEPT for your default branch
delete() {
	default_branch_name=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's/origin\///')
	current_branch_name=$(git branch --show-current)

	if [ "$default_branch_name" != "$current_branch_name" ]; then
		echo -e "\e[1;35mSwitching to $default_branch_name...\e[0m"
		git checkout $default_branch_name
	fi

	echo -e "\e[1;35mDeleting all branches EXCEPT $default_branch_name...\e[0m"
	git branch | grep -v "$default_branch_name" | xargs git branch -D
}
########

# Gets latest from your default branch. Also:
# --Stashes/Pops changes if any
# --Detects if you are currently on the default branch
# NOTE: This does a REBASE, not a MERGE
latest() {
	current_branch_name=$(git branch --show-current)
	default_branch_name=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's/origin\///')
	current_changes_count=$(git status --porcelain | wc -l)
	has_stashed_changes=false

	if [ "$current_changes_count" -gt 0 ]; then
		echo -e "\e[1;35mStashing $current_changes_count change$([ "$current_changes_count" -gt 1 ] && echo "s")...\e[0m"
		git add .
		git stash
		has_stashed_changes=true
		echo ""
	fi

	if [ "$default_branch_name" != "$current_branch_name" ]; then
		echo -e "\e[1;35mChecking out $default_branch_name...\e[0m"
		git checkout $default_branch_name --quiet
		echo ""
	fi

	echo -e "\e[1;35mPulling latest from $default_branch_name...\e[0m"
	git pull
	echo ""

	if [ "$default_branch_name" != "$current_branch_name" ]; then
		echo -e "\e[1;35mSwitching back to $current_branch_name...\e[0m"
		git checkout $current_branch_name --quiet
		echo ""

		echo -e "\e[1;35mRebasing $current_branch_name onto $default_branch_name...\e[0m"
		git rebase $default_branch_name
	fi

	if $has_stashed_changes; then
		echo -e "\e[1;35mPopping $current_changes_count change$([ "$current_changes_count" -gt 1 ] && echo "s")...\e[0m"
		git stash pop
	fi
}
########

# Gets latest from your default branch, then does force-with-lease push. Also:
# --Stashes/Pops changes if any
# --Detects if you are currently on the default branch
# NOTE: This does a REBASE, not a MERGE
latestpush() {
	current_branch_name=$(git branch --show-current)
	default_branch_name=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's/origin\///')
	current_changes_count=$(git status --porcelain | wc -l)
	has_stashed_changes=false

	if [ "$current_changes_count" -gt 0 ]; then
		echo -e "\e[1;35mStashing $current_changes_count change$([ "$current_changes_count" -gt 1 ] && echo "s")...\e[0m"
		git add .
		git stash
		has_stashed_changes=true
		echo ""
	fi

	if [ "$default_branch_name" != "$current_branch_name" ]; then
		echo -e "\e[1;35mChecking out $default_branch_name...\e[0m"
		git checkout $default_branch_name --quiet
		echo ""
	fi

	echo -e "\e[1;35mPulling latest from $default_branch_name...\e[0m"
	git pull
	echo ""

	if [ "$default_branch_name" != "$current_branch_name" ]; then
		echo -e "\e[1;35mSwitching back to $current_branch_name...\e[0m"
		git checkout $current_branch_name --quiet
		echo ""

		echo -e "\e[1;35mRebasing $current_branch_name onto $default_branch_name...\e[0m"
		git rebase $default_branch_name
		echo ""
	fi

	echo -e "\e[1;35mPushing $current_branch_name to GitHub...\e[0m"
	git push --force-with-lease

	if $has_stashed_changes; then
		echo -e "\e[1;35mPopping $current_changes_count change$([ "$current_changes_count" -gt 1 ] && echo "s")...\e[0m"
		git stash pop
	fi
}
########

# Displays number of stash entries
stashcount() {
	stash_count=$(git stash list | wc -l)

	if [ "$stash_count" -gt 0 ]; then
		echo "Stash is greater than 0"
	else
		echo "Stash is 0"
	fi
}
########

# Same thing as 'latest' script except does a merge instead of a rebase
mergelatest() {
	current_branch_name=$(git branch --show-current)
	default_branch_name=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's/origin\///')
	current_changes_count=$(git status --porcelain | wc -l)
	has_stashed_changes=false

	if [ "$current_changes_count" -gt 0 ]; then
		echo -e "\e[1;35mStashing $current_changes_count change$([ "$current_changes_count" -gt 1 ] && echo "s")...\e[0m"
		git add .
		git stash
		has_stashed_changes=true
		echo ""
	fi

	if [ "$default_branch_name" != "$current_branch_name" ]; then
		echo -e "\e[1;35mChecking out $default_branch_name...\e[0m"
		git checkout $default_branch_name --quiet
		echo ""
	fi

	echo -e "\e[1;35mPulling latest from $default_branch_name...\e[0m"
	git pull
	echo ""

	if [ "$default_branch_name" != "$current_branch_name" ]; then
		echo -e "\e[1;35mSwitching back to $current_branch_name...\e[0m"
		git checkout $current_branch_name --quiet
		echo ""
	fi

	echo -e "\e[1;Merging $default_branch_name into $current_branch_name...\e[0m"
	git merge $default_branch_name

	if $has_stashed_changes; then
		echo -e "\e[1;35mPopping $current_changes_count change$([ "$current_changes_count" -gt 1 ] && echo "s")...\e[0m"
		git stash pop
	fi
}
########

#rainbow() {
#  text="$1"
#  colors=("36" "35" "34" "33" "32" "31")
#  for (( i=0; i<${#text}; i++ )); do
#    color="${colors[$i % ${#colors[@]}]}"
#    echo -en "\e[1;${color}m${text:i:1}\e[0m"
#  done
#}

#blink() {
#	count=3
#	while [ $count -gt 0 ]; do
#		for i in $(seq 1 $count); do
#			echo -ne "."
#			sleep 0.5
#		done
#		echo -ne "\r   \r"
#	done
#}

# Function to display git commit history in a visually appealing way
# Work in Progress
function gitlog() {
  echo -e "\e[1;35mCommit history:\e[0m"
  git log --pretty=format:"%C(auto)%h %C(red)%cn %C(auto)%d %C(white)%s" --date=short -20 | sed -e "s/HEAD ->.*//g" | awk '{$1=$1};1' | tac | awk '{print NR".",$0}' | awk '{ if (NR%2 == 0) print "\033[38;5;141m"$0"\033[0m"; else print "\033[38;5;110m"$0"\033[0m"; }'
}
