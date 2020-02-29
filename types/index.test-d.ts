import {expectType} from 'tsd'
import * as clip from '..'

expectType<void>(clip.clearContents())

const data = 'the data to be write to clipboard'
const format = 'public.utf8-plain-text'
expectType<void>(clip.setStringData(data, format))
