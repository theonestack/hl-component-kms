def create_statement(config, type, default)
    statement = {}
    if config.has_key? type
      statement['Effect'] = config[type].has_key?('Effect') ? config[type]['Effect'] : default[type]['Effect']
      statement['Principal'] = config[type].has_key?('Principal') ? config[type]['Principal'] : default[type]['Principal']
      statement['Resource'] = config[type].has_key?('Resource') ? config[type]['Resource'] : default[type]['Resource']
      statement['Actions'] = config[type].has_key?('Actions') ? config[type]['Actions'] : default[type]['Actions']
      statement['Condition'] = config[type]['Conditions'] if config[type].has_key?('Conditions')
    else
      statement = default[type]
    end
    statement["Sid"] = type
    return statement
end