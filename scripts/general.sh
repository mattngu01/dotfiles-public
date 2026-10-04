#!/bin/bash

# anything related to tooling, aliases, and not affecting zsh behavior goes here

# keep this first, may link tools that are used in later things
eval "$(mise activate zsh)"

# Python
alias sv='python3 -m venv .venv'
alias cv='source .venv/bin/activate'
alias deac='deactivate'

# Docker / K8s
alias ddebug='docker run --rm -it --entrypoint /bin/bash'
alias k='kubectl'
alias ku='kubectl kustomize'
alias yless='jless --yaml'
alias kdebug-pod='kubectl run mattn-debugpod --image="nicolaka/netshoot" -i --tty --rm'
alias kdebug-container='kubectl debug -it --image="nicolaka/netshoot" --container="mattn-debugcontainer"'

# Terraform
alias tf='terraform'
alias tfplanlog='tf plan -out tf.plan -no-color | tee plan.log'

# General / Misc / Random
alias zsrc='source ~/.zshrc'
alias kssh='kitten ssh'
alias g='git'
alias n='nvim'
alias now='date -u +"%Y-%m-%dT%H-%M-%S%z"'

# AWS
alias chooseawslogin='aws sso login --profile $(aws configure list-profiles | sort | fzf)'

# disable interactive mode for kubectx
export KUBECTX_IGNORE_FZF=1
export EDITOR=vim

eval "$(zoxide init zsh)"

# github cli autocomplete
eval "$(gh completion -s zsh)"

alias pickprofile='aws configure list-profiles | fzf'
alias pickbranch='git branch | fzf'
alias pickawslogin='aws sso login --profile $(pickprofile)'

secretcreate() {
    local file="$1"
    local secret_name="$2"
    if [[ -z "$file" || -z "$secret_name" ]]; then
        echo "Usage: secret_create <file> <secret-name>" >&2
        return 1
    fi
    local encoded=$(base64 < "$file")
    aws secretsmanager create-secret --name "$secret_name" --secret-binary "$encoded"
}

secretpush() {
    local file="$1"
    local secret_id="$2"
    if [[ -z "$file" || -z "$secret_id" ]]; then
        echo "Usage: secret_push <file> <secret-id>" >&2
        return 1
    fi
    local encoded=$(base64 < "$file")
    aws secretsmanager put-secret-value --secret-id "$secret_id" --secret-binary "$encoded"
}

secretpull() {
    local secret_id="$1"
    local file="$2"
    if [[ -z "$secret_id" || -z "$file" ]]; then
        echo "Usage: secret_pull <secret-id> <file>" >&2
        return 1
    fi
    aws secretsmanager get-secret-value --secret-id "$secret_id" --query 'SecretBinary' --output text | base64 --decode > "$file"
}

secretcopy() {
    local source_arn="$1"
    local dest_profile="$2"
    local dest_name="$3"

    if [[ -z "$source_arn" || -z "$dest_profile" || -z "$dest_name" ]]; then
        echo "Usage: copysecret <source_arn> <dest_profile> <dest_secret_name>" >&2
        return 1
    fi

    if [[ ! "$source_arn" =~ ^arn:aws(-us-gov)?:secretsmanager:([^:]+):([0-9]+):secret:(.+)$ ]]; then
        echo "Error: invalid Secrets Manager ARN format" >&2
        return 1
    fi

    local region="${match[2]}"
    local account_id="${match[3]}"
    local secret_name="${match[4]}"

    # auto-detect source profile by matching account ID in ~/.aws/config
    local source_profile=""
    source_profile=$(awk -v acct="$account_id" '
        /^\[profile / { prof = $0; gsub(/\[profile |\]/, "", prof) }
        /sso_account_id/ && $0 ~ acct { print prof; exit }
    ' ~/.aws/config)

    if [[ -z "$source_profile" ]]; then
        source_profile="${AWS_PROFILE:-default}"
        echo "Warning: no profile found for account $account_id, using '$source_profile'" >&2
    else
        echo "Source: using profile '$source_profile'" >&2
    fi

    # fetch source secret metadata
    local metadata
    metadata=$(aws secretsmanager describe-secret \
        --secret-id "$source_arn" \
        --profile "$source_profile" \
        --region "$region" 2>&1) || {
        echo "Error: failed to describe source secret: $metadata" >&2
        return 1
    }

    local description tags
    description=$(echo "$metadata" | jq -r '.Description // empty')
    tags=$(echo "$metadata" | jq -c '.Tags // empty')

    # fetch source secret value
    local secret_value secret_binary
    local value_json
    value_json=$(aws secretsmanager get-secret-value \
        --secret-id "$source_arn" \
        --profile "$source_profile" \
        --region "$region" 2>&1) || {
        echo "Error: failed to get source secret value: $value_json" >&2
        return 1
    }

    secret_value=$(echo "$value_json" | jq -r '.SecretString // empty')
    secret_binary=$(echo "$value_json" | jq -r '.SecretBinary // empty')

    # check destination doesn't already exist
    if aws secretsmanager describe-secret \
        --secret-id "$dest_name" \
        --profile "$dest_profile" \
        --region "$region" &>/dev/null; then
        echo "Error: secret '$dest_name' already exists in profile '$dest_profile'" >&2
        return 1
    fi

    # build create-secret command
    local -a create_args=(
        --name "$dest_name"
        --profile "$dest_profile"
        --region "$region"
    )

    if [[ -n "$secret_value" ]]; then
        create_args+=(--secret-string "$secret_value")
    elif [[ -n "$secret_binary" ]]; then
        create_args+=(--secret-binary "$secret_binary")
    else
        echo "Error: source secret has no value" >&2
        return 1
    fi

    [[ -n "$description" ]] && create_args+=(--description "$description")
    [[ -n "$tags" && "$tags" != "[]" ]] && create_args+=(--tags "$tags")

    local result
    result=$(aws secretsmanager create-secret "${create_args[@]}" 2>&1) || {
        echo "Error: failed to create destination secret: $result" >&2
        return 1
    }

    echo "Copied '$secret_name' → '$dest_name' in profile '$dest_profile'"
    echo "$result" | jq -r '.ARN'
}

random_uuid() {
	uuidgen | awk '{print tolower($0)}'
}
