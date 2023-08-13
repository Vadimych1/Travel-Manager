import datetime, colors

loglevels: dict[str:int] = {
    "DEBUG": 0,
    "MESSAGE": 9,
    "WARN": 19,
    "ERROR": 29,
    "NONE": 30
}

min_log_level:int = 0
def Log(msg, level="msg"):
    """
    Levels:
    msg - INFO
    wmsg - DEBUG
    warn - WARN
    err - ERROR
    cerr - CRITICAL ERROR
    """
    msg:str = "["+str(datetime.datetime.now())+"] ["+("INFO" if level == "msg" else "ERROR" if level == "err" else "WARN" if level == "warn" else "DEBUG" if level == "wmsg" else "CRITICAL ERROR" if level == "cerr" else "INFO")+"] "+msg

    if level=="msg":
        msg = colors.color(msg, "rgb(0, 250, 20)")
    elif level=="err":
        msg = colors.color(msg, "rgb(250, 10, 10)")
    elif level=="warn":
        msg = colors.color(msg, "rgb(250, 250, 10)")
    elif level=="wmsg":
        msg = colors.color(msg, "rgb(0, 10, 240)")
    elif level=="cerr":
        msg = colors.color(msg, "rgb(0, 0, 255)")

    if min_log_level > 0:
        if level!="wmsg":
            if min_log_level < 10 and level == "msg":
              print(msg)
            elif min_log_level < 20 and level == "warn":
                print(msg)
            elif min_log_level < 30 and level == "err":
                print(msg)  
    else:
        print(msg)