# Deplpoying FluentD

Deploy all manifests.

Note: 
For elasticsearch create the following index template
```
{
    "index_patterns": [
        "nginx-nap-*"
    ],
    "template": {
        "settings": {
            "number_of_shards": 1
        },
        "mappings": {
            "dynamic_templates": [
                {
                    "string_fields": {
                        "match_mapping_type": "string",
                        "mapping": {
                            "norms": false,
                            "type": "text",
                            "fields": {
                                "keyword": {
                                    "ignore_above": 1024,
                                    "type": "keyword"
                                }
                            }
                        }
                    }
                }
            ],
            "_source": {
                "enabled": true
            },
            "properties": {
                "geoip": {
                    "type": "geo_point"
                },
                "serverIp": {
                    "type": "ip"
                },
                "clientIp": {
                    "type": "ip"
                }
            }
        },
        "aliases": {
            "mydata": {}
        }
    },
    "priority": 10
}

```