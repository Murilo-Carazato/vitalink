<?php

namespace App\Services;

use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\Log;
use Exception;

class EncryptionService
{
    /**
     * Encrypt sensitive medical data
     */
    public static function encryptSensitiveData(?string $data): ?string
    {
        if (empty($data)) {
            return null;
        }

        try {
            // Usar Laravel Crypt para criptografia
            return Crypt::encrypt($data);
        } catch (Exception $e) {
            Log::error('Encryption failed', [
                'error' => $e->getMessage(),
                'data_length' => strlen($data)
            ]);
            
            // Em caso de erro, retornar null para evitar armazenar dados não criptografados
            return null;
        }
    }

    /**
     * Decrypt sensitive medical data
     */
    public static function decryptSensitiveData(?string $encryptedData): ?string
    {
        if (empty($encryptedData)) {
            return null;
        }

        try {
            return Crypt::decrypt($encryptedData);
        } catch (Exception $e) {
            Log::error('Decryption failed', [
                'error' => $e->getMessage(),
                'encrypted_data_length' => strlen($encryptedData)
            ]);
            
            // Em caso de erro, retornar string indicando problema
            return '[DADOS_CRIPTOGRAFADOS_ILEGÍVEIS]';
        }
    }

    /**
     * Encrypt medical notes with additional validation
     */
    public static function encryptMedicalNotes(?string $notes): ?string
    {
        if (empty($notes)) {
            return null;
        }

        // Validar se contém informações médicas sensíveis
        if (self::containsSensitiveMedicalInfo($notes)) {
            return self::encryptSensitiveData($notes);
        }

        // Se não contém informações sensíveis, pode armazenar sem criptografia
        return $notes;
    }

    /**
     * Decrypt medical notes
     */
    public static function decryptMedicalNotes(?string $encryptedNotes): ?string
    {
        if (empty($encryptedNotes)) {
            return null;
        }

        // Verificar se está criptografado (criptografia do Laravel tem formato específico)
        if (self::isEncrypted($encryptedNotes)) {
            return self::decryptSensitiveData($encryptedNotes);
        }

        // Se não está criptografado, retornar como está
        return $encryptedNotes;
    }

    /**
     * Check if data contains sensitive medical information
     */
    private static function containsSensitiveMedicalInfo(string $data): bool
    {
        $sensitiveTerms = [
            'medicamento',
            'doença',
            'sintoma',
            'diagnóstico',
            'tratamento',
            'cirurgia',
            'alergia',
            'histórico médico',
            'pressão arterial',
            'diabetes',
            'hepatite',
            'HIV',
            'AIDS',
            'sífilis',
            'chagas',
            'malária',
            'remédio',
            'medicação',
            'complicação',
            'internação',
            'hospital',
            'emergência',
            'urgência',
        ];

        $dataLower = strtolower($data);

        foreach ($sensitiveTerms as $term) {
            if (strpos($dataLower, $term) !== false) {
                return true;
            }
        }

        return false;
    }

    /**
     * Check if data is encrypted (Laravel Crypt format)
     */
    private static function isEncrypted(string $data): bool
    {
        // Laravel encrypted data starts with 'eyJpdiI6' (base64 encoded JSON)
        return strpos($data, 'eyJ') === 0 && strlen($data) > 50;
    }

    /**
     * Sanitize data for logging (remove sensitive information)
     */
    public static function sanitizeForLogging(string $data): string
    {
        // Remover informações sensíveis para logs
        $patterns = [
            '/\b\d{3}\.\d{3}\.\d{3}-\d{2}\b/' => '[CPF_REMOVIDO]',
            '/\b\d{11}\b/' => '[CPF_REMOVIDO]',
            '/\b\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}\b/' => '[CNPJ_REMOVIDO]',
            '/\b\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\b/' => '[CARTAO_REMOVIDO]',
            '/\b\(\d{2}\)\s?\d{4,5}-?\d{4}\b/' => '[TELEFONE_REMOVIDO]',
            '/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b/' => '[EMAIL_REMOVIDO]',
        ];

        foreach ($patterns as $pattern => $replacement) {
            $data = preg_replace($pattern, $replacement, $data);
        }

        return $data;
    }

    /**
     * Hash sensitive data for search/indexing purposes
     */
    public static function hashForSearch(string $data): string
    {
        // Usar hash consistente para permitir busca sem revelar dados
        return hash('sha256', $data);
    }
}
