@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Get-Content '%~f0' | Select-Object -Skip 4 | Out-String | Invoke-Expression } catch { Write-Host '--- ERROR CAUGHT ---' -ForegroundColor Red; Write-Host $_.Exception.Message -ForegroundColor Yellow; Write-Host $_.ScriptStackTrace; Write-Host ''; Write-Host 'Press Enter to exit...' -ForegroundColor Cyan; [Console]::ReadLine() }"
exit /b

# --- BOOTSTRAP WPF & ASSEMBLIES ---
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

[System.Windows.Forms.Application]::EnableVisualStyles()
$global:appBaseDir = (Get-Location).Path

# --- XAML UI DEFINITION ---
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="File Rename Tool" Height="700" Width="1000" WindowStartupLocation="CenterScreen" Background="#1E293B" FontFamily="Segoe UI">
 
    <Window.Resources>
        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="#E2E8F0"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="VerticalAlignment" Value="Center"/>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Padding" Value="4,4"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
        </Style>
        <Style TargetType="ComboBox">
            <Setter Property="Padding" Value="4,4"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
        </Style>
        <Style TargetType="Button">
            <Setter Property="Padding" Value="15,4"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Background" Value="#334155"/>
            <Setter Property="Foreground" Value="#F8FAFC"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#0F172A"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#E2E8F0"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="VerticalAlignment" Value="Center"/>
        </Style>
        <Style TargetType="ListViewItem">
            <Setter Property="Padding" Value="3,2"/>
            <Setter Property="Foreground" Value="Black"/>
            <Style.Resources>
                <Style TargetType="TextBlock">
                    <Setter Property="Foreground" Value="Black"/>
                </Style>
            </Style.Resources>
        </Style>
    </Window.Resources>
    
    <Grid Margin="15">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <Border Grid.Row="0" Background="#2F3E51" CornerRadius="6" Padding="15" Margin="0,0,0,12" BorderBrush="#0F172A" BorderThickness="1">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="12"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="12"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Grid Grid.Row="0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="100"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Text="Directory:" FontWeight="SemiBold" HorizontalAlignment="Right" Margin="0,0,12,0"/>
                    <ComboBox Name="cmbDir" Grid.Column="1" IsEditable="True" Margin="0,0,8,0"/>
                    <Button Name="btnBrowse" Grid.Column="2" Content="..." Padding="12,2" Width="36" Margin="0,0,8,0" ToolTip="Browse for folder"/>
<Button Name="btnExplore" Grid.Column="3" Content="&#x1F4C1;" Padding="0" Width="36" ToolTip="Open directory in Windows Explorer" FontFamily="Segoe UI Emoji" Background="Transparent" BorderThickness="0" FontSize="16"/>
                </Grid>

                <Grid Grid.Row="2">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="100"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="100"/>
                        <ColumnDefinition Width="150"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Text="File Filter:" FontWeight="SemiBold" HorizontalAlignment="Right" Margin="0,0,12,0"/>
                    <TextBox Name="txtFilter" Grid.Column="1" Text="*" Margin="0,0,15,0" ToolTip="Shortcut: Alt+S"/>
                    <Button Name="btnFilter" Grid.Column="4" Content="Apply Filter" Width="100" FontWeight="SemiBold" Background="#0078D4" Foreground="White" BorderThickness="0"/>
                </Grid>

                <Grid Grid.Row="4">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="100"/>
                        <ColumnDefinition Width="150"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    
                    <TextBlock Text="Rename Rule:" FontWeight="SemiBold" HorizontalAlignment="Right" Margin="0,0,12,0"/>
                    <ComboBox Name="cmbRule" Grid.Column="1" Margin="0,0,15,0">
                        <ComboBoxItem>Find and Replace</ComboBoxItem>
                        <ComboBoxItem>Remove</ComboBoxItem>
                        <ComboBoxItem>Insert by Separator</ComboBoxItem>
                        <ComboBoxItem>Insert at Position</ComboBoxItem>
                        <ComboBoxItem>Pad Numbers</ComboBoxItem>
                    </ComboBox>

                    <StackPanel Name="pnlParams" Grid.Column="2" Orientation="Horizontal" Margin="0,0,15,0">
                        <TextBlock Name="lblP1" Text="Find:" Margin="0,0,8,0" VerticalAlignment="Center"/>
                        <TextBox Name="txtP1" Width="100" Margin="0,0,15,0"/>
                        
                        <TextBlock Name="lblP2" Text="Replace:" Margin="0,0,8,0" VerticalAlignment="Center" Visibility="Collapsed"/>
                        <TextBox Name="txtP2" Width="100" Margin="0,0,15,0" Visibility="Collapsed"/>
                        
                        <TextBlock Name="lblP5" Text="Instance:" Margin="0,0,8,0" VerticalAlignment="Center" Visibility="Collapsed"/>
                        <ComboBox Name="cmbP5" Width="60" Margin="0,0,15,0" IsEditable="True" Visibility="Collapsed"/>
                        
                        <TextBlock Name="lblP3" Text="Anchor:" Margin="0,0,8,0" VerticalAlignment="Center" Visibility="Collapsed"/>
                        <ComboBox Name="cmbP3" Width="110" Margin="0,0,15,0" Visibility="Collapsed"/>
                        
                        <TextBlock Name="lblP4" Text="Place:" Margin="0,0,8,0" VerticalAlignment="Center" Visibility="Collapsed"/>
                        <ComboBox Name="cmbP4" Width="80" Margin="0,0,15,0" Visibility="Collapsed"/>
                         
                        <Button Name="btnToggleDir" Content="Left-to-Right" Width="110" Margin="0,0,15,0" Visibility="Collapsed" ToolTip="Click to toggle direction / position / anchor"/>
                        <Button Name="btnTogglePlace" Content="After" Width="80" Margin="0,0,15,0" Visibility="Collapsed" ToolTip="Click to toggle placement (Before/After)"/>
                    </StackPanel>

                    <Button Name="btnPreview" Grid.Column="3" Content="Preview Rename" Width="130"/>
                </Grid>
            </Grid>
        </Border>

        <Border Grid.Row="1" Background="#2F3E51" CornerRadius="4" BorderBrush="#0F172A" BorderThickness="1" ClipToBounds="True">
            <ListView Name="lstResults" Background="#F1F5F9" Foreground="Black" BorderThickness="0" Margin="-6,-2,-6,0" SelectionMode="Extended">
                <ListView.Resources>
                    <Style TargetType="GridViewColumnHeader">
                        <Setter Property="Foreground" Value="#F8FAFC"/>
                        <Setter Property="Padding" Value="6,4"/>
                        <Setter Property="HorizontalContentAlignment" Value="Left"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="GridViewColumnHeader">
                                    <Border Background="#2F3E51" BorderBrush="#1E293B" BorderThickness="0,0,1,1" Padding="{TemplateBinding Padding}">
                                        <ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" VerticalAlignment="Center" />
                                    </Border>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </ListView.Resources>
                <ListView.View>
                    <GridView>
                        <GridViewColumn Width="40">
                            <GridViewColumn.Header>
                                <CheckBox Name="chkSelectAll" HorizontalAlignment="Center" ToolTip="Toggle All Checked States"/>
                            </GridViewColumn.Header>
                            <GridViewColumn.CellTemplate>
                                <DataTemplate>
                                    <CheckBox IsChecked="{Binding IsChecked, Mode=TwoWay}" HorizontalAlignment="Center"/>
                                </DataTemplate>
                            </GridViewColumn.CellTemplate>
                        </GridViewColumn>
                        <GridViewColumn Header="Original Name" DisplayMemberBinding="{Binding OriginalName}" Width="350"/>
                        <GridViewColumn Header="Proposed Name" DisplayMemberBinding="{Binding ProposedName}" Width="350"/>
                        <GridViewColumn Header="Date Modified" DisplayMemberBinding="{Binding DateModified}" Width="150"/>
                    </GridView>
                </ListView.View>
            </ListView>
        </Border>

        <Grid Grid.Row="2" Margin="0,12,0,0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBlock Name="statusLabel" Text="Ready." Foreground="#CBD5E1" VerticalAlignment="Center"/>
            
            <Button Name="btnUndo" Grid.Column="1" Content="UNDO LATEST" Width="130" Height="28" Margin="0,0,12,0" Background="#94A3B8" Foreground="#0F172A" FontWeight="Bold"/>
            <Button Name="btnExec" Grid.Column="2" Content="EXECUTE RENAME" Width="150" Height="28" Background="#10B981" Foreground="White" FontWeight="Bold" BorderThickness="0"/>
        </Grid>
    </Grid>
</Window>
"@

$xmlReader = (New-Object System.Xml.XmlNodeReader ([xml]$xaml))
$window = [Windows.Markup.XamlReader]::Load($xmlReader)

# --- WIRE CONTROLS ---
$cmbDir = $window.FindName("cmbDir")
$btnBrowse = $window.FindName("btnBrowse")
$btnExplore = $window.FindName("btnExplore")
$txtFilter = $window.FindName("txtFilter")
$btnFilter = $window.FindName("btnFilter")

$cmbRule = $window.FindName("cmbRule")
$lblP1 = $window.FindName("lblP1"); $txtP1 = $window.FindName("txtP1")
$lblP2 = $window.FindName("lblP2"); $txtP2 = $window.FindName("txtP2")
$lblP3 = $window.FindName("lblP3"); $cmbP3 = $window.FindName("cmbP3")
$lblP4 = $window.FindName("lblP4"); $cmbP4 = $window.FindName("cmbP4")
$lblP5 = $window.FindName("lblP5"); $cmbP5 = $window.FindName("cmbP5")

$btnPreview = $window.FindName("btnPreview")
$lstResults = $window.FindName("lstResults")
$chkSelectAll = $window.FindName("chkSelectAll")
$statusLabel = $window.FindName("statusLabel")
$btnUndo = $window.FindName("btnUndo")
$btnExec = $window.FindName("btnExec")

$btnToggleDir = $window.FindName("btnToggleDir")
$btnTogglePlace = $window.FindName("btnTogglePlace")

$global:dRecentDirs = @()
$script:masterFiles = @()
$script:currentResults = [System.Collections.ObjectModel.ObservableCollection[object]]::new()
$lstResults.ItemsSource = $script:currentResults

$logFile = Join-Path $global:appBaseDir "FileRenameWPF_Log.csv"
$configFile = Join-Path $global:appBaseDir "FileRenameWPF.json"

function Get-SafePath($path) {
    if ([string]::IsNullOrWhiteSpace($path)) { return $path }
    $p = $path.Replace("/", "\")
    if ($p.StartsWith("\\?\")) { return $p }
    if ($p -match "^[a-zA-Z]:\\") { return "\\?\" + $p }
    if ($p.StartsWith("\\")) { return "\\?\UNC\" + $p.Substring(2) }
    return $p
}

# --- DYNAMIC UI TOGGLES ---
$marginStandard = New-Object System.Windows.Thickness(0,0,15,0)
$marginTight = New-Object System.Windows.Thickness(0,0,4,0)
$marginGrouped = New-Object System.Windows.Thickness(0,0,25,0)

$cmbP3.Add_SelectionChanged({
    if (-not $cmbRule.SelectedItem) { return }
    $rule = $cmbRule.SelectedItem.Content.ToString()
    if ($rule -eq "Remove" -and $cmbP3.SelectedItem) {
        if ($cmbP3.SelectedItem.ToString() -match "From") {
            $lblP1.Text = "Count:"; $txtP1.Width = 40
        } else {
            $lblP1.Text = "Text:"; $txtP1.Width = 100
        }
    }
})

# --- Toggle button click handlers (for direction/place/anchor/position) ---
$btnToggleDir.Add_Click({
    $current = if ($btnToggleDir.Content) { $btnToggleDir.Content.ToString() } else { "" }
    switch ($current) {
        "Left-to-Right" { $btnToggleDir.Content = "Right-to-Left" }
        "Right-to-Left" { $btnToggleDir.Content = "Left-to-Right" }
        "From End"      { $btnToggleDir.Content = "From Start" }
        "From Start"    { $btnToggleDir.Content = "From End" }
        "Prefix"        { $btnToggleDir.Content = "Suffix" }
        "Suffix"        { $btnToggleDir.Content = "Prefix" }
        default         { $btnToggleDir.Content = "Left-to-Right" }
    }
})

$btnTogglePlace.Add_Click({
    $current = if ($btnTogglePlace.Content) { $btnTogglePlace.Content.ToString() } else { "" }
    if ($current -eq "After") {
        $btnTogglePlace.Content = "Before"
    } else {
        $btnTogglePlace.Content = "After"
    }
})

$cmbRule.Add_SelectionChanged({
    if (-not $cmbRule.SelectedItem) { return }
    $rule = $cmbRule.SelectedItem.Content.ToString()
    
    # Hide Everything by Default
    $lblP1.Visibility = 'Collapsed'; $txtP1.Visibility = 'Collapsed'
    $lblP2.Visibility = 'Collapsed'; $txtP2.Visibility = 'Collapsed'
    $lblP3.Visibility = 'Collapsed'; $cmbP3.Visibility = 'Collapsed'
    $lblP4.Visibility = 'Collapsed'; $cmbP4.Visibility = 'Collapsed'
    $lblP5.Visibility = 'Collapsed'; $cmbP5.Visibility = 'Collapsed'
    $btnToggleDir.Visibility = 'Collapsed'
    $btnTogglePlace.Visibility = 'Collapsed'
    
    # Reset specific styling
    $txtP1.Width = 100; $txtP2.Width = 100
    $txtP1.Margin = $marginStandard; $txtP2.Margin = $marginStandard
    $cmbP3.Margin = $marginStandard; $cmbP4.Margin = $marginStandard
    $btnToggleDir.Margin = $marginStandard; $btnTogglePlace.Margin = $marginStandard
    $txtP1.ToolTip = $null; $txtP2.ToolTip = $null

    # Clear input fields to prevent bleeding state between rules
    $txtP1.Text = ""; $txtP2.Text = ""; $cmbP5.Text = ""

    switch ($rule) {
        "Find and Replace" {
            $txtP1.ToolTip = "Text to Find"
            $txtP2.ToolTip = "Replace With"
            
            $txtP1.Visibility = 'Visible'; $txtP1.Margin = $marginTight; $txtP1.Width = 120
            $txtP2.Visibility = 'Visible'; $txtP2.Margin = $marginGrouped; $txtP2.Width = 120
            
            $btnToggleDir.Visibility = 'Visible'; $btnToggleDir.Margin = $marginTight; $btnToggleDir.Width = 110
            $btnToggleDir.Content = "Left-to-Right"
            
            $lblP5.Text = "Instance:"; $lblP5.Visibility = 'Visible'; $lblP5.Margin = $marginTight
            $cmbP5.Visibility = 'Visible'; $cmbP5.Items.Clear()
            1..4 | ForEach-Object { [void]$cmbP5.Items.Add($_.ToString()) }
            $cmbP5.Text = "1"
        }
        "Remove" {
            $lblP3.Text = "Method:"; $lblP3.Visibility = 'Visible'; $cmbP3.Visibility = 'Visible'
            $cmbP3.Items.Clear(); [void]$cmbP3.Items.Add("From Start"); [void]$cmbP3.Items.Add("From End"); [void]$cmbP3.Items.Add("Before Text"); [void]$cmbP3.Items.Add("After Text"); $cmbP3.SelectedIndex = 0
            
            $lblP1.Text = "Count:"; $lblP1.Visibility = 'Visible'; $txtP1.Visibility = 'Visible'; $txtP1.Width = 40
        }
        "Insert by Separator" {
            $txtP1.ToolTip = "Text to Insert"
            $txtP2.ToolTip = "Separator Character"
            
            $txtP1.Visibility = 'Visible'; $txtP1.Margin = $marginTight; $txtP1.Width = 120
            $txtP2.Visibility = 'Visible'; $txtP2.Margin = $marginGrouped; $txtP2.Width = 40
            
            $btnToggleDir.Visibility = 'Visible'; $btnToggleDir.Margin = $marginTight; $btnToggleDir.Width = 110
            $btnToggleDir.Content = "Right-to-Left"
            
            $btnTogglePlace.Visibility = 'Visible'; $btnTogglePlace.Margin = $marginGrouped; $btnTogglePlace.Width = 70
            $btnTogglePlace.Content = "After"
            
            $lblP5.Text = "Instance:"; $lblP5.Visibility = 'Visible'; $lblP5.Margin = $marginTight
            $cmbP5.Visibility = 'Visible'; $cmbP5.Items.Clear()
            1..4 | ForEach-Object { [void]$cmbP5.Items.Add($_.ToString()) }
            $cmbP5.Text = "1"
        }
        "Insert at Position" {
            $txtP1.Visibility = 'Visible'; $txtP1.Margin = $marginTight; $txtP1.Width = 120
            $txtP1.ToolTip = "Text to insert at the chosen position"
            
            $txtP2.Visibility = 'Visible'; $txtP2.Margin = $marginGrouped; $txtP2.Width = 50
            $txtP2.Text = "0"
            $txtP2.ToolTip = "Position (0-based). 0 = very start (prefix) or very end when using 'From End'. Most common & recommended value."
            $btnToggleDir.Visibility = 'Visible'; $btnToggleDir.Margin = $marginTight; $btnToggleDir.Width = 110
            $btnToggleDir.Content = "From End"
        }
        "Pad Numbers" {
            $lblP1.Text = "Length:"; $lblP1.Visibility = 'Visible'; $txtP1.Visibility = 'Visible'; $txtP1.Width = 40; $txtP1.Text = "3"
            
            $lblP3.Text = "Target Block:"; $lblP3.Visibility = 'Visible'; $cmbP3.Visibility = 'Visible'
            $cmbP3.Items.Clear()
            [void]$cmbP3.Items.Add("Last Block")
            [void]$cmbP3.Items.Add("First Block")
            [void]$cmbP3.Items.Add("Second Block")
            [void]$cmbP3.Items.Add("Third Block")
            $cmbP3.SelectedIndex = 0
        }
    }
})

function Optimize-AuditLog {
    if (-not (Test-Path -LiteralPath $logFile)) { return }
    
    $fileInfo = Get-Item -LiteralPath $logFile
    # 500KB limit (approx 512,000 bytes)
    if ($fileInfo.Length -gt 512000) {
        try {
            $lines = [System.IO.File]::ReadAllLines($logFile)
            if ($lines.Count -gt 1) {
                # Keep the most recent 3000 records
                $keepCount = 3000 
                if ($lines.Count -gt $keepCount) {
                    $startIndex = $lines.Count - $keepCount
                    $newLines = New-Object System.Collections.Generic.List[string]
                    $newLines.Add($lines[0]) # Preserve the CSV Header
                    
                    for ($i = $startIndex; $i -lt $lines.Count; $i++) {
                        $newLines.Add($lines[$i])
                    }
                    
                    [System.IO.File]::WriteAllLines($logFile, $newLines, [System.Text.Encoding]::UTF8)
                }
            }
        } catch { 
            Write-Host "Log optimization failed: $_" -ForegroundColor Yellow 
        }
    }
}

# --- LOAD CONFIGURATION ---
$targetRuleIndex = 0
if (Test-Path $configFile) {
    try {
        $settings = Get-Content $configFile -Raw | ConvertFrom-Json
        if ($settings.RecentDirectories) { $global:dRecentDirs = @($settings.RecentDirectories) }
        if ($settings.Directory) { $cmbDir.Text = $settings.Directory }
        if ($settings.FileFilter) { $txtFilter.Text = $settings.FileFilter }
        if ($settings.RuleIndex -ge 0) { $targetRuleIndex = $settings.RuleIndex }
        
        if ($settings.MainWidth -and $settings.MainHeight) {
            $window.Width = $settings.MainWidth; $window.Height = $settings.MainHeight
            $window.WindowStartupLocation = "Manual"
            $window.Left = $settings.MainX; $window.Top = $settings.MainY
        }
    } catch {}
}

# Force the UI creation event to fire by explicitly setting the index
$cmbRule.SelectedIndex = $targetRuleIndex

function Global:Update-HistoryList($List, $NewItem, $Max) {
    if ([string]::IsNullOrWhiteSpace($NewItem)) { return $List }
    $newList = [System.Collections.ArrayList]::new()
    [void]$newList.Add($NewItem)
    if ($null -ne $List) { foreach ($item in $List) { if ($item -ne $NewItem -and $newList.Count -lt $Max) { [void]$newList.Add($item) } } }
    return $newList.ToArray()
}

function Global:Sync-Combo($cmb, $list, $txt) {
    $cmb.Items.Clear()
    if ($list) { $list | ForEach-Object { if (-not [string]::IsNullOrWhiteSpace($_)) { [void]$cmb.Items.Add($_) } } }
    if ($txt) { $cmb.Text = $txt }
}

Global:Sync-Combo $cmbDir $global:dRecentDirs ""
if ([string]::IsNullOrWhiteSpace($cmbDir.Text)) { 
    $cmbDir.Text = if ($global:dRecentDirs.Count -gt 0) { $global:dRecentDirs[0] } elseif (Test-Path "$env:USERPROFILE\Documents") { "$env:USERPROFILE\Documents" } else { $global:appBaseDir }
}

# --- SAVE CONFIGURATION ---
$window.Add_Closing({
    $winWidth = if ($window.WindowState -eq 'Normal') { $window.ActualWidth } else { $window.RestoreBounds.Width }
    $winHeight = if ($window.WindowState -eq 'Normal') { $window.ActualHeight } else { $window.RestoreBounds.Height }
    $winLeft = if ($window.WindowState -eq 'Normal') { $window.Left } else { $window.RestoreBounds.Left }
    $winTop = if ($window.WindowState -eq 'Normal') { $window.Top } else { $window.RestoreBounds.Top }

    $appState = [ordered]@{ 
        RecentDirectories = $global:dRecentDirs
        Directory = $cmbDir.Text
        FileFilter = $txtFilter.Text
        RuleIndex = $cmbRule.SelectedIndex
        MainWidth = $winWidth; MainHeight = $winHeight
        MainX = $winLeft; MainY = $winTop
    }
    $appState | ConvertTo-Json -Depth 3 | Out-File $configFile -Encoding utf8
})

$btnBrowse.Add_Click({
    $fb = New-Object System.Windows.Forms.FolderBrowserDialog; $fb.SelectedPath = $cmbDir.Text
    if ($fb.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $cmbDir.Text = $fb.SelectedPath }
})

$btnExplore.Add_Click({
    $targetDir = $cmbDir.Text
    if ([string]::IsNullOrWhiteSpace($targetDir)) { return }
    $safeTarget = Get-SafePath $targetDir
    if (Test-Path -LiteralPath $safeTarget) {
        Start-Process "explorer.exe" -ArgumentList "`"$safeTarget`""
    }
})

$window.Add_PreviewKeyDown({
    param($sender, $e)
    if ($e.KeyboardDevice.Modifiers -match 'Alt' -and $e.SystemKey -eq 'S') {
        $e.Handled = $true; $txtFilter.Focus(); $txtFilter.SelectAll()
    }
})

$lstResults.Add_PreviewKeyDown({
    param($sender, $e)
    if ($e.Key -eq [System.Windows.Input.Key]::Space) {
        $e.Handled = $true
        if ($lstResults.SelectedItems.Count -gt 0) {
            $newState = -not $lstResults.SelectedItems[0].IsChecked
            foreach ($item in $lstResults.SelectedItems) { $item.IsChecked = $newState }
            $lstResults.Items.Refresh()
        }
    }
})

$lstResults.AddHandler([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent, 
    [System.Windows.RoutedEventHandler]{
        param($sender, $e)
        
        $headerClicked = $e.OriginalSource -as [System.Windows.Controls.GridViewColumnHeader]
        if ($null -eq $headerClicked -or $null -eq $headerClicked.Column) { return }

        $sortBy = $headerClicked.Column.Header.ToString()
        if ([string]::IsNullOrWhiteSpace($sortBy)) { return }

        # Map UI headers to exact object property names
        $propertyName = switch ($sortBy) {
            "Original Name" { "OriginalName" }
            "Proposed Name" { "ProposedName" }
            "Date Modified" { "DateModified" }
            default { $null }
        }

        if ($null -eq $propertyName) { return }

        $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView($lstResults.ItemsSource)
        
        $direction = [System.ComponentModel.ListSortDirection]::Ascending
        if ($view.SortDescriptions.Count -gt 0) {
            $currentSort = $view.SortDescriptions[0]
            if ($currentSort.PropertyName -eq $propertyName -and $currentSort.Direction -eq 'Ascending') {
                $direction = [System.ComponentModel.ListSortDirection]::Descending
            }
        }

        $view.SortDescriptions.Clear()
        $view.SortDescriptions.Add((New-Object System.ComponentModel.SortDescription($propertyName, $direction)))
        $view.Refresh()
    }
)

if ($chkSelectAll) {
    $chkSelectAll.Add_Click({
        $state = [bool]$this.IsChecked
        foreach ($item in $script:currentResults) { $item.IsChecked = $state }
        $lstResults.Items.Refresh()
    })
}

function Apply-DirectoryFilter {
    $dir = $cmbDir.Text
    $safeDir = Get-SafePath $dir
    if (-not (Test-Path -LiteralPath $safeDir)) { $statusLabel.Text = "Directory not found."; return }

    $global:dRecentDirs = Global:Update-HistoryList $global:dRecentDirs $dir 5
    Global:Sync-Combo $cmbDir $global:dRecentDirs $dir

    try {
        $dirInfo = New-Object System.IO.DirectoryInfo($safeDir)
        $files = $dirInfo.EnumerateFiles("*", [System.IO.SearchOption]::TopDirectoryOnly)
        $script:masterFiles = @()
        foreach ($f in $files) {
            $dispTag = $f.FullName
            if ($dispTag.StartsWith("\\?\UNC\")) { $dispTag = "\" + $dispTag.Substring(7) }
            elseif ($dispTag.StartsWith("\\?\")) { $dispTag = $dispTag.Substring(4) }
            
            $script:masterFiles += New-Object PSObject -Property @{
                IsChecked = $false; OriginalName = $f.Name; ProposedName = ""; DateModified = $f.LastWriteTime.ToString("yyyy-MM-dd HH:mm"); Tag = $dispTag
            }
        }
    } catch { $statusLabel.Text = "Error loading directory: $($_.Exception.Message)"; return }

    $filters = $txtFilter.Text -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    if ($filters.Count -eq 0) { $filters = @("*") }

    $checked = @(); $unchecked = @()
    foreach ($item in $script:masterFiles) {
        $match = $false
        foreach ($f in $filters) {
            $pattern = if ($f -notmatch "[\*\?]") { "*$f*" } else { $f }
            if ($item.OriginalName -like $pattern) { $match = $true; break }
        }
        $item.IsChecked = $match
        if ($match) { $checked += $item } else { $unchecked += $item }
    }

    # Build a fresh collection in memory, disconnected from the UI
    $newResults = [System.Collections.ObjectModel.ObservableCollection[object]]::new()
    foreach ($c in $checked) { $newResults.Add($c) }
    foreach ($u in $unchecked) { $newResults.Add($u) }
    
    # Swap the references and re-bind in one single UI update
    $script:currentResults = $newResults
    $lstResults.ItemsSource = $script:currentResults
    
    if ($chkSelectAll) { $chkSelectAll.IsChecked = ($script:masterFiles.Count -gt 0 -and $unchecked.Count -eq 0) }
    $statusLabel.Text = "Filtered: $($checked.Count) matches out of $($script:masterFiles.Count) files."
}

$script:filterTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:filterTimer.Interval = [TimeSpan]::FromMilliseconds(600)
$script:filterTimer.Add_Tick({ $script:filterTimer.Stop(); Apply-DirectoryFilter })
$txtFilter.Add_TextChanged({ $script:filterTimer.Stop(); $script:filterTimer.Start() })
$btnFilter.Add_Click({ $script:filterTimer.Stop(); Apply-DirectoryFilter })

$btnPreview.Add_Click({
    if (-not $cmbRule.SelectedItem) { return }
    $rule = $cmbRule.SelectedItem.Content.ToString()

    foreach ($item in $script:currentResults) {
        if (-not $item.IsChecked) { $item.ProposedName = ""; continue }
        
        $old = $item.OriginalName; $new = $old
        try {
            $base = [System.IO.Path]::GetFileNameWithoutExtension($old)
            $ext = [System.IO.Path]::GetExtension($old)
            
            switch ($rule) {
                "Find and Replace" { 
                    $op1 = $txtP1.Text; $op2 = $txtP2.Text
                    if ($op1) {
                        $anchor = if ($btnToggleDir.Content) { $btnToggleDir.Content.ToString() } else { "Left-to-Right" }
                        $inst = 1; if ($cmbP5.Text -match '^\d+$') { $inst = [int]$cmbP5.Text }
                        if ($inst -lt 1) { $inst = 1 }
                        
                        $targetIdx = -1
                        if ($anchor -eq "Right-to-Left") {
                            $currIdx = $old.Length
                            for ($i = 0; $i -lt $inst; $i++) {
                                $currIdx = $old.LastIndexOf($op1, $currIdx - 1)
                                if ($currIdx -lt 0) { break }
                            }
                            $targetIdx = $currIdx
                        } else {
                            $currIdx = -1
                            for ($i = 0; $i -lt $inst; $i++) {
                                $currIdx = $old.IndexOf($op1, $currIdx + 1)
                                if ($currIdx -lt 0) { break }
                            }
                            $targetIdx = $currIdx
                        }
                        
                        if ($targetIdx -ge 0) {
                            $new = $old.Substring(0, $targetIdx) + $op2 + $old.Substring($targetIdx + $op1.Length)
                        }
                    }
                }
                "Remove" {
                    $method = $cmbP3.SelectedItem.ToString()
                    if ($method -eq "From Start") {
                        if ($txtP1.Text -match '^\d+$') { $c = [int]$txtP1.Text; if ($c -gt 0 -and $c -lt $old.Length) { $new = $old.Substring($c) } }
                    } elseif ($method -eq "From End") {
                        if ($txtP1.Text -match '^\d+$') { $c = [int]$txtP1.Text; if ($c -gt 0 -and $c -lt $base.Length) { $new = $base.Substring(0, $base.Length - $c) + $ext } }
                    } elseif ($method -eq "Before Text") {
                        if ($txtP1.Text) {
                            $idx = $base.IndexOf($txtP1.Text); if ($idx -ge 0) { $new = $base.Substring($idx + $txtP1.Text.Length) + $ext }
                        }
                    } elseif ($method -eq "After Text") {
                        if ($txtP1.Text) {
                            $idx = $base.IndexOf($txtP1.Text); if ($idx -ge 0) { $new = $base.Substring(0, $idx) + $ext }
                        }
                    }
                }
                "Insert by Separator" {
                    $op1 = $txtP1.Text; $sep = $txtP2.Text
                    if ($op1 -and $sep) {
                        $anchor = if ($btnToggleDir.Content) { $btnToggleDir.Content.ToString() } else { "Right-to-Left" }
                        $place = if ($btnTogglePlace.Content) { $btnTogglePlace.Content.ToString() } else { "After" }
                        $inst = 1; if ($cmbP5.Text -match '^\d+$') { $inst = [int]$cmbP5.Text }
                        if ($inst -lt 1) { $inst = 1 }
                        
                        $targetIdx = -1
                        if ($anchor -eq "Right-to-Left") {
                            $currIdx = $base.Length
                            for ($i = 0; $i -lt $inst; $i++) {
                                $currIdx = $base.LastIndexOf($sep, $currIdx - 1)
                                if ($currIdx -lt 0) { break }
                            }
                            $targetIdx = $currIdx
                        } else {
                            $currIdx = -1
                            for ($i = 0; $i -lt $inst; $i++) {
                                $currIdx = $base.IndexOf($sep, $currIdx + 1)
                                if ($currIdx -lt 0) { break }
                            }
                            $targetIdx = $currIdx
                        }

                        if ($targetIdx -ge 0) {
                            if ($place -eq "After") { $new = $base.Substring(0, $targetIdx + $sep.Length) + $op1 + $base.Substring($targetIdx + $sep.Length) + $ext } 
                            else { $new = $base.Substring(0, $targetIdx) + $op1 + $base.Substring($targetIdx) + $ext }
                        }
                    }
                }
                "Insert at Position" {
                    $op1 = $txtP1.Text; if ($op1 -and $txtP2.Text -match '^\d+$') {
                        $pos = [int]$txtP2.Text
                        $anchorVal = if ($btnToggleDir.Content) { $btnToggleDir.Content.ToString() } else { "From End" }
                        if ($anchorVal -eq "From End") {
                            $insertIdx = [Math]::Max(0, $base.Length - $pos)
                            $new = $base.Substring(0, $insertIdx) + $op1 + $base.Substring($insertIdx) + $ext
                        } else {
                            $insertIdx = [Math]::Min($base.Length, $pos)
                            $new = $base.Substring(0, $insertIdx) + $op1 + $base.Substring($insertIdx) + $ext
                        }
                    }
                }
                "Pad Numbers" {
                    if ($txtP1.Text -match '^\d+$') {
                        $target = $cmbP3.SelectedItem.ToString(); $padLen = [int]$txtP1.Text
                        $matches = [regex]::Matches($base, '\d+')
                        if ($matches.Count -gt 0) {
                            $m = $null
                            if ($target -eq "Last Block") { $m = $matches[$matches.Count - 1] } 
                            elseif ($target -eq "First Block") { $m = $matches[0] } 
                            elseif ($target -eq "Second Block" -and $matches.Count -ge 2) { $m = $matches[1] }
                            elseif ($target -eq "Third Block" -and $matches.Count -ge 3) { $m = $matches[2] }
                            
                            if ($null -ne $m) {
                                # Strip existing leading zeros first
                                $stripped = $m.Value.TrimStart('0')
                                
                                # If the number was literally just zeros (e.g. "000"), preserve a single zero
                                if ($stripped -eq '') { $stripped = '0' }
                                
                                # Apply the exact requested padding
                                $padded = $stripped.PadLeft($padLen, '0')
                                $new = $base.Substring(0, $m.Index) + $padded + $base.Substring($m.Index + $m.Length) + $ext
                            }
                        }
                    }
                }
            }
        } catch {}

	if ($old -ceq $new) { $item.ProposedName = "--- NO CHANGE ---" } else { $item.ProposedName = $new }
    }
    
    $lstResults.Items.Refresh(); $statusLabel.Text = "Preview generated."
})

$btnExec.Add_Click({
    if (-not (Test-Path -LiteralPath $logFile)) { "Timestamp,Original Name,New Name,Folder" | Out-File $logFile -Encoding utf8 }
    
    $count = 0
    foreach ($item in $script:currentResults) {
        if (-not $item.IsChecked) { continue }
        
        $oldName = $item.OriginalName; $newName = $item.ProposedName
        $oldPath = $item.Tag; $folder = [System.IO.Path]::GetDirectoryName($oldPath)
        $safeOldPath = Get-SafePath $oldPath
        
        # 1. Catch absolute matches, but let case-only differences slip through
        if ([string]::IsNullOrWhiteSpace($newName) -or ($oldName -eq $newName -and $oldName -ceq $newName) -or $newName -match "ERROR" -or $newName -eq "--- NO CHANGE ---") { continue }
        
        if ($newName -match '[<>:"/\\|?*]') { 
            $item.ProposedName = "ERROR: Invalid Chars"
            continue 
        }
        
        # 2. Determine if this is strictly a capitalization change
        $isCaseOnly = ($oldName -cne $newName -and $oldName -eq $newName)
        
        $safeNewPath = Get-SafePath (Join-Path $folder $newName)
        
        # 3. Only throw "File Exists" if it's NOT a case-only rename
        if (-not $isCaseOnly -and (Test-Path -LiteralPath $safeNewPath)) { 
            $item.ProposedName = "ERROR: File Exists"
            continue 
        }
        
        try {
            if ($isCaseOnly) {
                # 4. Execute temporary swap to bypass NTFS case-collision
                $tempName = [guid]::NewGuid().ToString() + "_TMP"
                $safeTempPath = Get-SafePath (Join-Path $folder $tempName)
                Rename-Item -LiteralPath $safeOldPath -NewName $tempName -ErrorAction Stop
                Rename-Item -LiteralPath $safeTempPath -NewName $newName -ErrorAction Stop
            } else {
                Rename-Item -LiteralPath $safeOldPath -NewName $newName -ErrorAction Stop
            }
            
            "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')),`"$oldName`",`"$newName`",`"$folder`"" | Out-File $logFile -Append -Encoding utf8
            $count++
            
            $item.OriginalName = $newName
            $item.Tag = $safeNewPath
            $item.ProposedName = "SUCCESS"
            $item.IsChecked = $false
        } catch { $item.ProposedName = "ERROR: Failed" }
    }
    
    if ($count -gt 0) { 
        $statusLabel.Text = "Successfully renamed $count files." 
    } 
    $lstResults.Items.Refresh() 
    
    Optimize-AuditLog
})

# --- IMMUTABLE UNDO ENGINE ---
$btnUndo.Add_Click({
    if (-not (Test-Path -LiteralPath $logFile)) { [System.Windows.MessageBox]::Show("No rename log found.", "Undo Error", 0, 48) | Out-Null; return }

    $history = Import-Csv -LiteralPath $logFile -ErrorAction SilentlyContinue
    if (-not $history -or $history.Count -eq 0) { [System.Windows.MessageBox]::Show("No rename history to undo.", "Undo", 0, 64) | Out-Null; return }

    $lastTimestamp = $history[-1].Timestamp
    $latestBatch = $history | Where-Object { $_.Timestamp -eq $lastTimestamp }

    $undoneCount = 0
    $newTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    foreach ($item in $latestBatch) {
        $folder = $item.Folder
        $oldName = $item.'Original Name'
        $newName = $item.'New Name'
        
        $safeCurrent = Get-SafePath (Join-Path $folder $newName)
        $safeOriginal = Get-SafePath (Join-Path $folder $oldName)

        if ((Test-Path -LiteralPath $safeCurrent) -and (-not (Test-Path -LiteralPath $safeOriginal))) {
            try { 
                Rename-Item -LiteralPath $safeCurrent -NewName $oldName -ErrorAction Stop
                
                "$newTime,`"$newName`",`"$oldName`",`"$folder`"" | Out-File $logFile -Append -Encoding utf8
                $undoneCount++ 
            } catch {}
        }
    }

    if ($undoneCount -gt 0) {
        Apply-DirectoryFilter
        $statusLabel.Text = "Successfully reverted $undoneCount file(s)."
    } else {
        [System.Windows.MessageBox]::Show("Could not undo changes. Files may have been moved or target names already exist.", "Undo Failed", 0, 16) | Out-Null
    }
    
    Optimize-AuditLog
})

$window.Add_ContentRendered({ if (-not [string]::IsNullOrWhiteSpace($cmbDir.Text)) { Apply-DirectoryFilter } })
$window.ShowDialog() | Out-Null