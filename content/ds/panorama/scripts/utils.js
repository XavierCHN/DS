function print(s)
{
	$.Msg(s);
}
function PrefixInteger(num, length) {
	return (Array(length).join('0') + num).slice(-length);
}
