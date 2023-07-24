<#
.SYNOPSIS
Colored console output

.DESCRIPTION
Print colored text on the console. 
To specify the color you have to use color tags

.PARAMETER Text
The text to print

.EXAMPLE
Write-ColoredOutput -Text "uncolored text<blue>blue text</>uncolored text<green>green text</>"
#>
function Write-ColoredOutput() {
    param (
        [string]$Text = ''
    );

    <# 
        Define opening and closing tag and build regex
        Example <red>text</>
    #>
    $colorTagOpen  = '<';
    $colorTagClose = '>';
    $regexEndTag   = '</>';
    $regexStartTag = [string]::Format('{0}[A-Za-z]+{1}', $colorTagOpen, $colorTagClose);
    $textParts     = [regex]::Split($Text, "($regexStartTag.*?$regexEndTag)");

    
    # Loop over all parts
    foreach ($part in $textParts) {

        # Check if current part is color tagged
        if ($part -match "^$regexStartTag.*?$regexEndTag$") {

            # Get color tag
            $colorTag   = [regex]::Matches($cuttedPart, $regexStartTag).Value;

            # Get color out of color tag
            $color      = $colorTag.substring($colorTagOpen.Length, $colorTag.Length - ($colorTagOpen.Length + $colorTagClose.Length));

            # Cut opening tag
            $finalPart  = $cuttedPart.substring($colorTag.Length, $cuttedPart.length - $colorTag.Length);
            
            # Cut closing tag
            $cuttedPart = $part.substring(0, $part.Length - $regexEndTag.Length);

            <# 
                Try colored printing. If color does not exist, 
                catch runtime error and simply print normal
            #>
            try {
                Write-Host -NoNewline -ForegroundColor $color $finalPart;
            } catch {
                Write-Host -NoNewline $part;
            }

            continue;
        }

        # Print non tagged, uncolored part
        Write-Host -NoNewline $part;
    }
}
