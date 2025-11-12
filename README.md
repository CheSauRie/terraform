Terrform

## Notes

* Định nghĩa nhiều máy ảo trong biến `vms` (map) để tạo hàng loạt từ cùng một template. Mỗi phần tử có thể chỉ định CPU, RAM, disk, datastore riêng.
* Block guest customization chỉ chạy ở lần apply đầu tiên để đặt hostname/DNS và để nguyên DHCP. Terraform được cấu hình `ignore_changes` nên việc đổi IP trong biến sẽ không phá hủy VM.
* Để đổi IP, cập nhật các trường `new_ipv4_*` của VM tương ứng rồi `terraform apply`. Terraform sẽ SSH vào VM và cập nhật file netplan thay vì clone lại máy ảo.
* Có thể override `netplan_interface`, `ssh_user`, `ssh_private_key` theo từng VM nếu tên interface hoặc tài khoản đăng nhập khác nhau.
