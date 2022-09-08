alias ls='ls -aFC'
export CLOUDABILITY_HOME=$PWD
source venv/bin/activate # source in python venv
alias noxraydev=". $CLOUDABILITY_HOME/setup_build_env.sh"  # use this non-xray build and test (noxray)
alias xraydev=". $CLOUDABILITY_HOME/setup_build_env.sh --use-xray"  # use this for xray demaon, build and test only
alias nobuild=". $CLOUDABILITY_HOME/setup_build_env.sh --no-use-ec2"  # use this for non build terminals
alias
echo "Use noxraydev or xraydev for CLOUDABILITY_HOME when you build and sam local start-api terminal work"
echo "Use nobuild for CLOUDABILITY_HOME whe you work other than building and running the api (e.g., ec2 metadata server)"