# Run this file just like this:   . filename.sh
cd /root
. ~/minio-output.properties

export AWS_ACCESS_KEY_ID=$access_key
export AWS_SECRET_ACCESS_KEY=$secret_key
export AWS_S3_ENDPOINT="10.0.0.2:9000"
export SPARK_LOCAL_IP="127.0.0.1"
export AWS_REGION="us-east-1"
export MINIO_REGION="us-east-1"
export DEPENDENCIES="org.apache.iceberg:iceberg-spark-runtime-3.3_2.12:1.1.0"
export AWS_SDK_VERSION=2.19.19
export AWS_MAVEN_GROUP="software.amazon.awssdk"
export AWS_PACKAGES=(
"bundle"
"url-connection-client"
)
for pkg in "${AWS_PACKAGES[@]}"; do
        export DEPENDENCIES+=",$AWS_MAVEN_GROUP:$pkg:$AWS_SDK_VERSION"
done

echo $DEPENDENCIES
echo $AWS_S3_ENDPOINT
echo $access_key
echo $secret_key
cd $SPARK_HOME

spark-sql --packages org.apache.iceberg:iceberg-spark-runtime-3.3_2.12:1.1.0,\
software.amazon.awssdk:bundle:2.19.19,\
software.amazon.eventstream:eventstream:1.0.1,\
software.amazon.awssdk:url-connection-client:2.19.19,\
software.amazon.awssdk:utils:2.19.19,\
org.reactivestreams:reactive-streams:1.0.3,\
software.amazon.awssdk:annotations:2.19.19,\
org.slf4j:slf4j-api:1.7.30,\
software.amazon.awssdk:http-client-spi:2.19.19,\
software.amazon.awssdk:metrics-spi:2.19.19 \
--conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
--conf spark.sql.cli.print.header=true \
--conf spark.sql.catalog.icecatalog=org.apache.iceberg.spark.SparkCatalog \
--conf spark.sql.catalog.icecatalog.catalog-impl=org.apache.iceberg.jdbc.JdbcCatalog \
--conf spark.sql.catalog.icecatalog.uri=jdbc:postgresql://127.0.0.1:5432/icecatalog \
--conf spark.sql.catalog.icecatalog.jdbc.user=icecatalog \
--conf spark.sql.catalog.icecatalog.jdbc.password=supersecret1 \
--conf spark.sql.catalog.icecatalog.warehouse=s3://iceberg-data \
--conf spark.sql.catalog.icecatalog.io-impl=org.apache.iceberg.aws.s3.S3FileIO \
--conf spark.sql.catalog.icecatalog.s3.endpoint="http://10.0.0.2:9000" \
--conf spark.sql.catalog.sparkcatalog=org.apache.iceberg.spark.SparkSessionCatalog \
--conf spark.sql.defaultCatalog=icecatalog \
--conf spark.eventLog.enabled=true \
--conf spark.eventLog.dir=/opt/spark/spark-events \
--conf spark.history.fs.logDirectory=/opt/spark/spark-events \
--conf spark.sql.catalogImplementation=in-memory \
--conf spark.sql.warehouse.dir=/opt/spark/warehouse
