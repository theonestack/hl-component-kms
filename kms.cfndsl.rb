CloudFormation do 
    Description "#{component_name} - #{component_version}"

    tags = []
    tags << { Key: 'Environment', Value: Ref(:EnvironmentName) }
    tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }

    extra_tags.each { |key,value| tags << { Key: key, Value: value } } if defined? extra_tags

    keys.each do |key|

        policy_document = {}
        policy_document["Statement"] = []
        policy_document["Statement"] << create_statement(key, 'administration', default)
        policy_document["Statement"] << create_statement(key, 'usage', default)

        safe_key_name = key['alias'].capitalize.gsub('_','').gsub('-','')

        KMS_Alias("#{safe_key_name}Alias") do
            AliasName FnSub("alias/${EnvironmentName}-#{key['alias']}")
            TargetKeyId Ref("#{safe_key_name}")
            DeletionPolicy 'Retain'
        end
  
        KMS_Key("#{safe_key_name}") do
            Description key['description'] ? key['description'] : "#{key['alias']} KMS Key"
            DeletionPolicy 'Retain'
            PendingWindowInDays key['key_deletion_time'] ? key['key_deletion_time'] : 7
            KeyPolicy policy_document
        end

        Output("#{safe_key_name}Key") {
            Value(FnGetAtt("#{safe_key_name}", 'Arn'))
            Export FnSub("${EnvironmentName}-#{safe_key_name}-key")
        }

    end if defined? keys
end