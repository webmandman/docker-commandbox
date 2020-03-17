#!/bin/sh

# credit: https://medium.com/@basi/docker-environment-variables-expanded-from-secrets-8fa70617b3bc

: ${ENV_SECRETS_DIR:=/run/secrets}

env_secret_debug()
{
    if [ ! -z "$ENV_SECRETS_DEBUG" ]; then
        echo -e "\033[1m$@\033[0m"
    fi
}

# usage: env_secret_expand VAR
#    ie: env_secret_expand 'XYZ_DB_PASSWORD'
# (will check for "$XYZ_DB_PASSWORD" variable value for a placeholder that defines the
#  name of the docker secret to use instead of the original value. For example:
# XYZ_DB_PASSWORD=<<SECRET:my-db.secret>>
env_secret_expand() {
    var="$1"
    eval val=\$$var

    if secret_name=$(expr match "$val" "<<SECRET:\([^}]\+\)>>$"); then
        secret="${ENV_SECRETS_DIR}/${secret_name}"
    elif [[ ${var:(-5)} == '_FILE' ]]; then
        secret=$val
    fi

    if [ $secret ]; then
        env_secret_debug "Secret file for $var: $secret"
        if [ -f "$secret" ]; then
            val=$(cat "${secret}")
            if ${var:(-5)}='_FILE'; then
                var=$(echo $var| cut -d'_' -f 1);
            fi
            export "$var"="$val"
            env_secret_debug "Expanded variable: $var=$val"
        else
            export "$var"=""
            env_secret_debug "Secret file does not exist! $secret"
        fi
    fi
}

env_secrets_expand() {
    for env_var in $(printenv | cut -f1 -d"=")
    do
        env_secret_expand $env_var
    done

    if [ ! -z "$ENV_SECRETS_DEBUG" ]; then
        echo -e "\n\033[1mExpanded environment variables\033[0m"
        printenv
    fi
}

env_secrets_expand