function Test-Numeric ($number) {
    return $number -Match "^[\d\.]+$";
}
