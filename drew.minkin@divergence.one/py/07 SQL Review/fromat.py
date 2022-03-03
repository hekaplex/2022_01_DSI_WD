for data in raw_data:
    report_str = """{} is {} years old and is {} meter tall weiging about {} kg.\n
    Has a hsitory of family illness: {}.\n
    Presently suffering from a heart disease: {}
    """.format(data["Name"], data["Age"], data["Height"], data["Weight"], data["Disease_history"], data["Heart_problem"])
    #.format(data["Name"], data["Age"], data["Height"], data["Weight"], data["Disease_history"], data["Heart_problem"])
    
    print(report_str)