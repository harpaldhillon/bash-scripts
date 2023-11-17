pipeline {
    agent any

    stages {
        stage('List Tags Quay.io') {
            steps {
                script {
                    result_set = listImageTagsQuayIo("prometheus-operator/prometheus-operator")
                    println("result_set: $result_set")
                }
            }
        }
    }
}

def listImageTagsQuayIo(def IMAGE)
{
    page=1
    max_page=10
    data=''
    response=''
    response_subset=''
    base_url="https://quay.io/api/v1/repository/$IMAGE/tag"
    
    result = sh (script: """
    set +x
    while [ \$((page)) -le ${max_page} ] ; do
      response=`curl -L -s ${base_url}?page=\$((page))`
      response_subset=`echo \$response|jq -r '.tags | [.[] | {name: .name, last_modified: .last_modified}]'`
      data=`jq -n --argjson old "\$(jq -n "\${data}")" --argjson new "\${response_subset}" '\$old + \$new'` # Concatenate data
      
      # Check if the response is empty
        if [ -z "\$response" ]; then
            break
        fi
      page=\$((page + 1))
    done
    set -x
    echo \$data
    """, returnStdout: true).trim()
    
    return result
}
