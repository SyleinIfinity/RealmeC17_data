
/*
    Bước 1: Tạo Bucket S3
- Vào AWS S3 -> ấn create bucket
    + Chọn loại bucket: S3 standard
    + Đặt tên bucket: vd: khanh-bucket
    + Chọn region: ví dụ: Asia Pacific (Singapore) ap-southeast-1
    + bỏ tích block all connection
    + Ấn create bucket
- Vào bucket vừa tạo -> ấn upload -> ấn add files -> chọn file web-dashboard.zip đã tải về từ trước -> ấn upload
Vào phần permissions của bucket:
    + Ở Bucket policy ấn Edit
    + dán đoạn json sau:
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "Statement1",
                    "Effect": "Allow",
                    "Principal": "*",
                    "Action": "s3:GetObject",
                    "Resource": ".../*" thay ... bằng arn của bucket bản thân dùng(không xóa "/*")
                }
            ]
        }
    + Ấn "Save"

- Upload 1 file nào đó và lưu lại các thông tin sau đây(bỏ vô notepad đi):
    + tên bucket
    + arn của bucket
    + key: vd: Quan.jpg hoặc images/Quan.jpg
    + size: vd: 228.5
    + Entity Tag: vd: 0960f812b0615ec019748a3d0a3456c9

    Bước 2:
- tải lambda_function.zip về máy
- tạo 1 lambda đặt tên: vd: khanh-lambda
    + chọn loại default author from scratch
    + chọn runtime: Python 3.9
    + chọn quyền execution role: create a new role with basic lambda permissions
    + ấn create function
- vào phần code của lambda function:
    + ấn upload file và chọn lambda_function.zip đã tải về -> ấn save -> zip tự động giải nén
- vào phần cấu hình (configuration) của lambda function:
    + Vô mục permissions
    + ấn vào role name để vào IAM (dưới phần execution role)
- Ở IAM:
    + Hiện tại đang ở tab roles
    + Ấn vào policies dưới tab roles ở thanh bên trái
    + Ấn create policies
    + Chọn tab JSON
    + Dán đoạn code trong file policy.json vào
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "VisualEditor0",
                    "Effect": "Allow",
                    "Action": [
                        "s3:GetObject",
                        "logs:CreateLogStream",
                        "logs:CreateLogGroup",
                        "logs:PutLogEvents"
                    ],
                    "Resource": [
                        ".../*", -> đổi ... thành arn của bucket mình 
                        "arn:aws:logs:*:*:*" -> Nếu lỗi thì thay bằng "*"
                    ]
                }
            ]
        }
    + Ấn next
    + Đặt tên cho policy của mình -> Ấn tạo policy
    + Quay lại role hồi nãy -> Ấn Attach policies -> nhập tên policy vừa tạo -> tích và ấn add permission

    Bước 3: add trigger

- Ấn Add trigger
    + ở mục Trigger configuration: gõ s3 và chọn
    + chọn tới bucket mình dùng
    + Event types: đảm bảo có: All object create events
    + lướt xuống dưới tích ô I acknowledge that usi......
    + Ấn add

    Bước 4:

- Vô phần test của lambda
    + đặt tên cho Test event nếu là lần đầu tạo
    + Dán đoạn code sau:
        {
          "Records": [
            {
              "eventVersion": "2.0",
              "eventSource": "aws:s3",
              "awsRegion": "us-east-1",
              "eventTime": "1970-01-01T00:00:00.000Z",
              "eventName": "ObjectCreated:Put",
              "userIdentity": {
                "principalId": "EXAMPLE"
              },
              "requestParameters": {
                "sourceIPAddress": "127.0.0.1"
              },
              "responseElements": {
                "x-amz-request-id": "EXAMPLE123456789",
                "x-amz-id-2": "EXAMPLE123/5678abcdefghijklambdaisawesome/mnopqrstuvwxyzABCDEFGH"
              },
              "s3": {
                "s3SchemaVersion": "1.0",
                "configurationId": "testConfigRule",
                "bucket": {
                  "name": "...",
                  "ownerIdentity": {
                    "principalId": "EXAMPLE"
                  },
                  "arn": "..."
                },
                "object": {
                  "key": "...",
                  "size": ...,
                  "eTag": "...",
                  "sequencer": "0A1B2C3D4E5F678901"
                }
              }
            }
          ]
        }
    + các dấu ... là các dữ liệu cần thay lần lượt theo thứ tự thông tin yêu cầu lưu ở bước 1

- Ngang đây lưu và test là xong.

!!! TRONG TRƯỜNG HỢP KHÔNG RA KẾT QUẢ
- Vô mục code dán đoạn code sau vào lambda_function.py

    import boto3
    import os
    import sys
    import uuid
    from urllib.parse import unquote_plus
    from PIL import Image
    import pymysql

    s3_client = boto3.client('s3')

    def image_inf(image_path):
        with Image.open(image_path) as image:
            w, h = image.size
        return w, h

    def lambda_handler(event, context):
        # Lặp qua từng file trong sự kiện S3
        for record in event['Records']:
            bucket = record['s3']['bucket']['name']
            key = unquote_plus(record['s3']['object']['key'])
            tmpkey = key.replace('/', '')
            download_path = '/tmp/{}{}'.format(uuid.uuid4(), tmpkey)

            # Tải file từ S3 xuống thư mục /tmp của Lambda
            s3_client.download_file(bucket, key, download_path)

            # Lấy thông tin kích thước ảnh
            w, h = image_inf(download_path)

            # In thông tin ra CloudWatch Log, giống như trong file PDF
            print(f"File name {key}, width {w}, height {h}")

        # Trả về thông báo thành công sau khi xử lý tất cả
        return {
            'statusCode': 200,
            'body': 'Processing complete.'
        }
        
- ấn deploy -> test lại là ra
        
        