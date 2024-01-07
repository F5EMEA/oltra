# Deplpoying FluentD

Deploy all manifests.

Note: 
For elasticsearch create the following 2 index template for NAP and NGINX Access Logs


## NAP Logs
```
curl --location --request PUT 'x.x.x.x:9200/_index_template/nginx-nap-logs' \
--header 'Content-Type: application/json' \
--data '{
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
}'
```


## Access Logs
```
curl --location --request PUT 'x.x.x.x:9200/_index_template/nginx-access-logs' \
--header 'Content-Type: application/json' \
--data '{
    "index_patterns": [
        "nginx-access-*"
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
                "address": {
                    "type": "ip"
                }
            }
        },
        "aliases": {
            "mydata": {}
        }
    },
    "priority": 10
}'
```

