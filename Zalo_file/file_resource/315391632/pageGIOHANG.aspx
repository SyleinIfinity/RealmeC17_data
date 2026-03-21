<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPageUser.Master" AutoEventWireup="true" CodeBehind="pageGIOHANG.aspx.cs" Inherits="baitap.pageGIOHANG" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="center_content">
        <div class="center_title_bar">Latest Products</div>
        <asp:GridView ID="grvCART" runat="server" AutoGenerateColumns="False" CellPadding="4" ForeColor="#333333" GridLines="None" ShowFooter="True"
            BackColor="White" Height="232px" Width="567px">
            <Columns>
                <asp:BoundField DataField="MASANPHAM" HeaderText="Mã s&#7843;n ph&#7849;m" />
                <asp:BoundField DataField="TENSANPHAM" HeaderText="Tên s&#7843;n ph&#7849;m" />
                <asp:BoundField DataField="DONGIA" HeaderText="&#272;&#417;n giá" />
                <asp:BoundField DataField="SOLUONG" HeaderText="S&#7889; l&#432;&#7907;ng" />
                <asp:BoundField DataField="MOTA" HeaderText="Mô t&#7843;" />
                <asp:ImageField DataImageUrlField="HINHANH" DataImageUrlFormatString="Images/{0}" HeaderText="Hình &#7843;nh" />
                <asp:TemplateField HeaderText="Xoá">
                    <ItemTemplate>
                        <asp:CheckBox ID="ckbREMOVEITEM" runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
            <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
            <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
            <RowStyle BackColor="#EFF3FB" />
            <AlternatingRowStyle BackColor="White" />
            <EditRowStyle BackColor="#2461BF" />
            <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
            <SortedAscendingCellStyle BackColor="#F5F7FB" />
            <SortedAscendingHeaderStyle BackColor="#6D95E1" />
            <SortedDescendingCellStyle BackColor="#E9EBEF" />
            <SortedDescendingHeaderStyle BackColor="#4870BE" />
        </asp:GridView>
        <asp:Button ID="btnDELETE" runat="server" Text="Xoá hàng" OnClick="btnDELETE_Click" />
    </div>
</asp:Content>
