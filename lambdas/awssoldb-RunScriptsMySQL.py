import boto3
import json
import logging
import pymysql
from pymysql.constants import CLIENT
from pymysql.err import ProgrammingError
from pymysql.err import DataError
from pymysql.err import IntegrityError
from pymysql.err import NotSupportedError
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def GetConnection(data, host, port, dbname):
    try:
        username = data["username"]
        password = data["password"]
        port = int(port)

        conn = pymysql.connect(
            host=host,
            user=username,
            passwd=password,
            port=port,
            db=dbname,
            connect_timeout=5,
            client_flag=CLIENT.MULTI_STATEMENTS
        )

        return conn
    except pymysql.OperationalError:
        return None


def DumpTable(cur, tablename):
    cur.execute("SHOW TABLES")
    data = ""
    tables = []
    if tablename == "ALL":
        logger.info("Dumping all tables")
        for table in cur.fetchall():
            logger.info("Dumping table: " + table[0])
            tables.append(table[0])
    else:
        logger.info("Dumping table: " + tablename)
        tables.append(tablename)

    for table in tables:
        data += "DROP TABLE IF EXISTS `" + str(table) + "`;"

        cur.execute("SHOW CREATE TABLE `" + str(table) + "`;")
        data += "\n" + str(cur.fetchone()[1]) + ";\n\n"

        cur.execute("SELECT * FROM `" + str(table) + "`;")
        for row in cur.fetchall():
            data += "INSERT INTO `" + str(table) + "` VALUES("
            first = True
            for field in row:
                if not first:
                    data += ', '
                data += '"' + str(field) + '"'
                first = False


            data += ");\n"
        data += "\n\n"
    return data

def lambda_handler(event, context):

    awsregion = os.environ["AWS_REGION"]
    rdsclient = boto3.client("rds", region_name=awsregion)

    cluster = event["cluster"]
    dbname = event["dbname"]
    response = rdsclient.describe_db_clusters(DBClusterIdentifier=cluster)

    cluarn = response["DBClusters"][0]["DBClusterArn"]
    host = response["DBClusters"][0]["Endpoint"]
    port = response["DBClusters"][0]["Port"]

    secretname = event["secretname"]
    secclient = boto3.client("secretsmanager", region_name=awsregion)
    response = secclient.get_secret_value(
        SecretId=secretname,
    )

    secretstring = str(response["SecretString"])
    obj = json.loads(secretstring)
    data = obj

    conn = GetConnection(data, host, port, dbname)

    if conn:
        logger.info("Connection opened")

        bucketname = event["bucketname"]
        s3client = boto3.client("s3", region_name=awsregion)

        try:
            key = event["key"]

            logger.info(key)

            response = s3client.get_object(Bucket=bucketname, Key=key)

            with conn.cursor() as cur:
                data = ""
                if "dump" in key:
                    logger.info("Dumping tables")
                    data = DumpTable(cur, "ALL")
                else:
                    logger.info("File opened")
                    content = response["Body"].read().decode("utf-8")
                    cur.execute(content)
                    logger.info("rowcount: {} message: {}".format(cur.rowcount, cur._result.message))
                    for row in cur.fetchall():
                        data += str(row) + "\n"
                logger.info(data)
                #s3client.put_object(Bucket=bucketname, Key=key+"_result", Body=data)
                logger.info("Executed")
        except ProgrammingError as err:
            logger.info("Scripts run with a ProgrammingError")
            logger.info(err.args[0])
            logger.info(err.args[1])
            raise ValueError("Scripts run with a ProgrammingError")
        except DataError as err:
            logger.info("Scripts run with a DataError")
            logger.info(err.args[0])
            logger.info(err.args[1])
            raise ValueError("Scripts run with a DataError")
        except IntegrityError as err:
            logger.info("Scripts run with a IntegrityError")
            logger.info(err.args[0])
            logger.info(err.args[1])
            raise ValueError("Scripts run with a IntegrityError")
        except NotSupportedError as err:
            logger.info("Scripts run with a NotSupportedError")
            logger.info(err.args[0])
            logger.info(err.args[1])
            raise ValueError("Scripts run with a NotSupportedError")
        except Exception as error:
            logger.info("Scripts run with errors. Unknow error")
            logger.error(str(error))
            raise ValueError("Scripts run with errors. Unknow error:", str(error))
        finally:
            logger.info("Connection closed")
            conn.close()

        result = "Scripts run"
    else:
        logger.info("Unable to log into the Aurora MySQL database, scripts not run")
        raise ValueError(
            "Unable to log into the Aurora MySQL database, scripts not run"
        )

    return {"statusCode": 200, "body": result}
