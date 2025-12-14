import * as Minio from 'minio';
import { log } from '@/utils/log';

const s3Host = process.env.S3_HOST;
const s3Port = process.env.S3_PORT ? parseInt(process.env.S3_PORT, 10) : undefined;
const s3UseSSL = process.env.S3_USE_SSL ? process.env.S3_USE_SSL === 'true' : true;

const s3Enabled = !!(s3Host && process.env.S3_ACCESS_KEY && process.env.S3_SECRET_KEY);

export const s3client = s3Enabled ? new Minio.Client({
    endPoint: s3Host!,
    port: s3Port,
    useSSL: s3UseSSL,
    accessKey: process.env.S3_ACCESS_KEY!,
    secretKey: process.env.S3_SECRET_KEY!,
}) : null;

export const s3bucket = process.env.S3_BUCKET || '';

export const s3host = process.env.S3_HOST || '';

export const s3public = process.env.S3_PUBLIC_URL || '';

export async function loadFiles() {
    if (!s3client) {
        log({ module: 'files' }, 'S3 not configured - file storage disabled');
        return;
    }
    await s3client.bucketExists(s3bucket);
}

export function getPublicUrl(path: string) {
    return `${s3public}/${path}`;
}

export type ImageRef = {
    width: number;
    height: number;
    thumbhash: string;
    path: string;
}
