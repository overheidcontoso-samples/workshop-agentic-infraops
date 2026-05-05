@description('Container App resource ID')
param containerAppId string

@description('Environment name for naming')
param environmentName string

// Action Group (minimal — SRE Agent picks up alerts via managed resources)
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag-sre-workshop-${environmentName}'
  location: 'global'
  properties: {
    groupShortName: 'SREWorkAG'
    enabled: true
  }
}

// Alert: HTTP 5xx errors on Container App
// One alert keeps it simple — the agent investigates the root cause
resource http5xxAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-http-5xx-${environmentName}'
  location: 'global'
  properties: {
    description: 'Alert when demo app returns HTTP 5xx errors — triggers SRE Agent investigation'
    severity: 3
    enabled: true
    scopes: [
      containerAppId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'http5xx'
          metricName: 'Requests'
          metricNamespace: 'microsoft.app/containerapps'
          operator: 'GreaterThan'
          threshold: 5
          timeAggregation: 'Total'
          dimensions: [
            {
              name: 'statusCodeCategory'
              operator: 'Include'
              values: [
                '5xx'
              ]
            }
          ]
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}
