------------bài 1
-----in dòng chữ
Create proc sp_hello
       @Ten nvarchar(30)
as
begin
  print 'Hello' + @Ten;
end;

exec sp_hello N' Tuấn';

-------tính tổng
Create proc sp_sum
@s1 int,@s2 int
as
begin
declare @tong int;
set @tong=@s1+@s2;
print N'Tổng là: ' + cast(@tong as varchar);
end;

exec sp_sum 10, 40

------in ra tổng số chẳn
Create proc sp_sum2
@n int
as
begin
declare @sum int, @i int;
set @sum = 0;
set @i =1;
while @i <= @n
begin
if @i%2=0
begin
set @sum = @sum + @i;
end;
set @i = @i+1;
end;
print N'Tổng các số chẳn: '+ cast(@sum as varchar);
end;

exec sp_sum2 10

--------in ra ướt chung lớn nhất
create proc sp_UCLN
@a int, @b int
as
begin
declare @temp int;
if @a > @b
begin
select @temp = @a, @a = @b, @b = @temp;
end
while @b % @a !=0
begin
select @temp = @a, @a = @b % @a, @b = @temp;
end;
print N'Ước chung lớn nhất: '+ cast(@a as varchar);
end;

exec sp_UCLN 20,9;

---------bài 2
-----xuất thông tin nv
create proc sp_NV
@MaNV nvarchar(9)
as
begin
select*from NHANVIEN where MANV = @MaNV;
end;

exec sp_NV '004'

--------sô lượng nv tham gia đề án
create proc sp_NVthamgiaDA
@MaDA int
as
begin
select COUNT(ma_nvien) as 'Số lượng' from PHANCONG where MADA = @MaDA;
end

exec [dbo].[sp_NVthamgiaDA] 1;

--------nhân viên tham gia đề án có mã đề án là @MaDA
create proc sp_NVthamgiaDA@MaDA
@MaDA int, @DDiem_DA nvarchar(15)
as
begin
select * from DEAN
select COUNT(b.ma_nvien) as 'Số lượng'
from DEAN a inner join PHANCONG b on a.MADA = b.MADA
where a.MADA = @MaDA and a.DDIEM_DA = @DDiem_DA;
end;

exec [dbo].[sp_NVthamgiaDA@MaDA] 1, N'Vũng Tàu';

------xuất thông tin các nhân viên có trưởng phòng
create proc sp_NVtruongphong
@TrPHG nvarchar(9)
as
begin
select b.*from PHONGBAN a inner join NHANVIEN b on a.MAPHG =b.PHG
where a.TRPHG=@TrPHG
end;

exec [dbo].[sp_NVtruongphong] '008'

------Ktra NV
create proc sp_ktraNV
@MaNV nvarchar(9), @MaPB int
as
begin
declare @Dem int;
select @Dem = COUNT(manv) from NHANVIEN where MANV= @MaNV and PHG = @MaPB;
return @Dem;
end;

declare @result int;
exec @result =[dbo].[sp_ktraNV] '005', 5;
select @result;

--Đếm Nhân viên ở tỉnh thành
create procedure DemNva
@cityvar nvarchar (30)
as
declare @num int
select @num = count (*) from nhanvien
where DCHI like '%' + @cityvar
return @num
go
declare @tongso int
exec @tongso = DemNv 'TP HCM'
select @tongso 
go

-----bài 3
------Thêm phòng ban có tên CNTT
create proc sp_insertPB
@MaPB int, @TenPB nvarchar(15),
@MaTP nvarchar(9), @NgayNhanChuc date
as
begin
   if (exists(select*from PhongBan where MaPHG =@MaPB))
      print 'Them that bai'
   else
      begin
          insert into PHONGBAN (MAPHG, TENPHG, TRPHG, NG_NHANCHUC)
          values (@MaPB, @TenPB, @MaTP, @NgayNhanChuc)
          print 'them thanh cong'
      end
end
exec sp_insertPB '8','CNTT','008','2022-11-29'

-----------Cập nhật phòng ban có tên CNTT thành phòng IT.
create proc sp_capnhatphongban
@TENPHGCU nvarchar(15),@TENPHG nvarchar(15),
@MAPHG int,@TRPHG nvarchar(9),@NG_NHANCHUC date
as
begin
	update PHONGBAN
	set TENPHG = @TENPHG, MAPHG = @MAPHG, TRPHG = @TRPHG, NG_NHANCHUC = @NG_NHANCHUC
	where TENPHG = @TENPHGCU;
end;

exec sp_capnhatphongban 'CNTT', 'IT', 10, '005', '1-1-2020';

------------Thêm một nhân viên vào bảng NhanVien, tất cả giá trị đều truyền dưới dạng tham số đầu vào với điều kiện
create proc sp_themNV
	@HONV nvarchar(15),@TENLOT nvarchar(15),@TENNV nvarchar(15),@MANV nvarchar(9),
	@NGSINH datetime,@DCHI nvarchar(30),@PHAI nvarchar(3),@LUONG float,@PHG int
as
begin
	if not exists(select*from PHONGBAN where TENPHG = 'IT')
	begin
		print N'Nhân viên phải trực thuộc phòng IT';
		return;
	end;
	declare @MA_NQL nvarchar(9);
	if @LUONG > 25000
		set @MA_NQL = '005';
	else
		set @MA_NQL = '009';
	declare @age int;
	select @age = DATEDIFF(year,@NGSINH,getdate()) + 1;
	if @PHAI = 'Nam' and (@age < 18 or @age >60)
	begin
		print N'Nam phải có độ tuổi từ 18-65';
		return;
	end;
	else if @PHAI = 'Nữ' and (@age < 18 or @age >60)
	begin
		print N'Nữ phải có độ tuổi từ 18-60';
		return;
	end;
	INSERT INTO NHANVIEN(HONV,TENLOT,TENNV,MANV,NGSINH,DCHI,PHAI,LUONG,MA_NQL,PHG)
		VALUES(@HONV,@TENLOT,@TENNV,@MANV,@NGSINH,@DCHI,@PHAI,@LUONG,@MA_NQL,@PHG)
end;

exec sp_themNV N'Nguyễn',N'Hoàng',N'Tuấn','022','12-5-1977',N'Hà Nội','Nam',30000,6;