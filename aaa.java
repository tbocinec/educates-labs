{
        "type": "record",
        "name": "Person",
        "namespace": "example",
        "fields": [
        { "name": "id",  "type": "string" },
        { "name": "age", "type": "int" },
        {
        "name": "status",
        "type": {
        "type": "enum",
        "name": "Status",
        "symbols": ["ACTIVE", "INACTIVE"]
        }
        }
        ]
        }