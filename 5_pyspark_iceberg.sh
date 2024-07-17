# First cd to $HOME_SPARK then run pyspark
# after that in the pyspark session run this:

# import SparkSession
from pyspark.sql import SparkSession

# create SparkSession
spark = SparkSession.builder \
     .appName("Python Spark SQL example") \
     .config("spark.jars.packages", "org.apache.iceberg:iceberg-spark-runtime-3.3_2.12:1.1.0,software.amazon.awssdk:bundle:2.19.19,software.amazon.awssdk:url-connection-client:2.19.19") \
     .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
     .config("spark.sql.catalog.icecatalog", "org.apache.iceberg.spark.SparkCatalog") \
     .config("spark.sql.catalog.icecatalog.catalog-impl", "org.apache.iceberg.jdbc.JdbcCatalog") \
     .config("spark.sql.catalog.icecatalog.uri", "jdbc:postgresql://127.0.0.1:5432/icecatalog") \
     .config("spark.sql.catalog.icecatalog.jdbc.user", "icecatalog") \
     .config("spark.sql.catalog.icecatalog.jdbc.password", "supersecret1") \
     .config("spark.sql.catalog.icecatalog.warehouse", "s3://iceberg-data") \
     .config("spark.sql.catalog.icecatalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
     .config("spark.sql.catalog.icecatalog.s3.endpoint", "http://10.0.0.2:9000") \
     .config("spark.sql.catalog.sparkcatalog", "icecatalog") \
     .config("spark.eventLog.enabled", "true") \
     .config("spark.eventLog.dir", "/opt/spark/spark-events") \
     .config("spark.history.fs.logDirectory", "/opt/spark/spark-events") \
     .config("spark.sql.catalogImplementation", "in-memory") \
     .getOrCreate()

