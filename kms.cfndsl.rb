CloudFormation do 
    Description "#{component_name} - #{component_version}"



    tags = []
    tags << { Key: 'Environment', Value: Ref(:EnvironmentName) }
    tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }

    extra_tags.each { |key,value| tags << { Key: key, Value: value } } if defined? extra_tags

    keys.each do |key, config|
        safe_key_name = key.capitalize.gsub('_','').gsub('-','')
    
        policy_document = {}
        policy_document["Statement"] = []
    
        config['key-policy'].each do |sid, statement_config|
            statement = {}
            statement["Sid"] = sid
            statement['Effect'] = statement_config.has_key?('effect') ? statement_config['effect'] : "Allow"
            statement['Principal'] = statement_config.has_key?('principal') ? statement_config['principal'] : {AWS: FnSub("arn:aws:iam::${AWS::AccountId}:root")}
            statement['Resource'] = statement_config.has_key?('resource') ? statement_config['resource'] : "*"
            statement['Action'] = statement_config['actions']
            statement['Condition'] = statement_config['conditions'] if statement_config.has_key?('conditions')
            policy_document["Statement"] << statement
        end


        KMS_Alias("#{safe_key_name}Alias") do
            AliasName FnSub("alias/${EnvironmentName}-#{key}")
            TargetKeyId Ref("#{safe_key_name}Key")
        end
  
        KMS_Key("#{safe_key_name}Key") do
            Description config['description'] ? config['description'] : "#{key} KMS Key"
            DeletionPolicy 'Retain'
            PendingWindowInDays config['key_deletion_time'] ? config['key_deletion_time'] : 7
            KeyPolicy policy_document
        end

        Output("#{safe_key_name}Key") {
            Value(FnGetAtt("#{safe_key_name}Key", 'Arn'))
            Export FnSub("${EnvironmentName}-#{component_name}-key")
        }

    end if defined? keys
end